use aiken/dict.{Dict}
use aiken/list
use aiken/transaction.{
  Input, Output, ScriptContext, Spend, Transaction, find_input,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{AssetName, PolicyId, Value, from_asset, merge}
use aiken_virtual_dex/common.{
  compare_address, compare_script_address, inputs_at, key_signed,
  only_input_datum_with, only_minted_token, output_inline_datum, outputs_at,
  redeemer_from, value_geq,
}
use aiken_virtual_dex/types.{
  CancelOrder, EmergencyCancel, MassTakeOrder, OracleDatum, TakeOrder,
  VirtualDexDatum, VirtualDexRedeemer,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}

pub fn accumulate_all_to_return_value(
  long_token: (PolicyId, AssetName),
  short_token: (PolicyId, AssetName),
  inputs: List<Input>,
  own_address: Address,
) -> (Dict<Address, (Address, Value)>, Int) {
  list.foldr(
    inputs,
    (dict.new(), 0),
    fn(x: Input, acc: (Dict<Address, (Address, Value)>, Int)) {
      let is_from_same_address = own_address == x.output.address
      when is_from_same_address is {
        True -> {
          expect VirtualDexDatum {
            trade_account_address,
            change_account_address,
            is_long,
            list_price_times_1mil,
            sell_lot_size,
          }: VirtualDexDatum = output_inline_datum(x.output)
          let current_item = dict.get(acc.1st, trade_account_address)
          let (to_return_value, long_quantity) =
            if is_long {
              (
                from_asset(
                  long_token.1st,
                  long_token.2nd,
                  list_price_times_1mil * sell_lot_size / 1000000,
                ),
                list_price_times_1mil * sell_lot_size / 1000000,
              )
            } else {
              (
                from_asset(
                  short_token.1st,
                  short_token.2nd,
                  list_price_times_1mil * sell_lot_size / 1000000,
                ),
                sell_lot_size,
              )
            }
          when current_item is {
            None ->
              (
                dict.insert(
                  acc.1st,
                  trade_account_address,
                  (change_account_address, to_return_value),
                  compare_script_address,
                ),
                acc.2nd + long_quantity,
              )
            Some((change_account_address, value)) ->
              (
                dict.insert(
                  acc.1st,
                  trade_account_address,
                  (change_account_address, merge(value, to_return_value)),
                  compare_script_address,
                ),
                acc.2nd + long_quantity,
              )
          }
        }
        False -> acc
      }
    },
  )
}

pub fn accumuate_all_payment_value(
  outputs: List<Output>,
) -> Dict<Address, Value> {
  list.foldr(
    outputs,
    dict.new(),
    fn(x: Output, acc: Dict<Address, Value>) {
      let this_address = x.address
      let current_item = dict.get(acc, this_address)
      when current_item is {
        None -> dict.insert(acc, x.address, x.value, compare_address)
        Some(val) ->
          dict.insert(acc, x.address, merge(val, x.value), compare_address)
      }
    },
  )
}

pub fn virtual_dex_logic(
  oracle_nft: PolicyId,
  emergency_token: PolicyId,
  param_long_token: (PolicyId, AssetName),
  param_short_token: (PolicyId, AssetName),
  datum: VirtualDexDatum,
  redeemer: VirtualDexRedeemer,
  context: ScriptContext,
) {
  let ScriptContext { purpose, transaction } = context

  when redeemer is {
    TakeOrder -> {
      let Transaction { reference_inputs, inputs, outputs, .. } = transaction
      expect OracleDatum { operation_key, .. }: OracleDatum =
        only_input_datum_with(reference_inputs, oracle_nft, "")
      expect Spend(own_utxo) = purpose
      expect Some(own_input) = find_input(transaction.inputs, own_utxo)
      let own_address = own_input.output.address
      let (trade_payment_map, _long_token_quantity) =
        accumulate_all_to_return_value(
          param_long_token,
          param_short_token,
          inputs,
          own_address,
        )
      let payment_values = accumuate_all_payment_value(outputs)
      let is_operation_key_signed =
        key_signed(transaction.extra_signatories, operation_key)

      // - Accumulate proceeds supposed send to order creators, check output value to them
      // 1. Look throught all inputs ->
      //       if from same address -> get (trade_account_address, change_account_address, receive_value)
      // 2. Merge all results above with same trade_account_address
      // 3. Check each unique trade_account_address, if outputs to trade_account + change_account >= to_receive
      let is_token_paid_to_inidividual_maker =
        fn(payment_item) {
          let (
            trade_account_address,
            (change_account_address, to_receive_value),
          ) = payment_item
          let maybe_trade_received_value =
            dict.get(payment_values, trade_account_address)
          let maybe_change_received_value =
            dict.get(payment_values, change_account_address)
          when (maybe_trade_received_value, maybe_change_received_value) is {
            (Some(trade_received_value), Some(change_received_value)) ->
              value_geq(
                merge(trade_received_value, change_received_value),
                to_receive_value,
              )
            (Some(trade_received_value), None) ->
              value_geq(trade_received_value, to_receive_value)
            (None, Some(change_received_value)) ->
              value_geq(change_received_value, to_receive_value)
            (None, None) -> False
          }
        }
      let is_token_paid_to_makers =
        trade_payment_map
          |> dict.to_list()
          |> list.all(is_token_paid_to_inidividual_maker)
      is_operation_key_signed && is_token_paid_to_makers
    }

    MassTakeOrder { take_order_input } -> {
      let Transaction { inputs, redeemers, .. } = transaction
      expect Spend(own_utxo) = purpose
      expect Some(own_input) = find_input(transaction.inputs, own_utxo)
      let own_address = own_input.output.address
      let maybe_redeemer =
        redeemer_from(redeemers, inputs, take_order_input, own_address)
      when maybe_redeemer is {
        Some(raw_target_redeemer) -> {
          expect target_redeemer: VirtualDexRedeemer = raw_target_redeemer
          when target_redeemer is {
            TakeOrder -> True
            _ -> False
          }
        }
        _ -> False
      }
    }

    CancelOrder -> {
      expect Spend(own_utxo) = purpose
      let Transaction {
        inputs,
        outputs,
        reference_inputs,
        extra_signatories,
        ..
      } = transaction
      let VirtualDexDatum { trade_account_address, .. } = datum
      expect Some(input) = find_input(transaction.inputs, own_utxo)
      expect [own_input] = inputs_at(inputs, input.output.address)
      expect [trade_output] = outputs_at(outputs, trade_account_address)
      expect OracleDatum { operation_key, .. }: OracleDatum =
        only_input_datum_with(reference_inputs, oracle_nft, "")
      let is_order_value_returned = own_input.output.value == trade_output.value
      let is_operation_key_signed = key_signed(extra_signatories, operation_key)
      is_order_value_returned && is_operation_key_signed
    }
    EmergencyCancel -> {
      let Transaction { mint, .. } = transaction
      let VirtualDexDatum { trade_account_address, .. } = datum
      let is_emergency_token_burnt =
        only_minted_token(
          mint,
          emergency_token,
          get_emergency_token_name(trade_account_address),
          -1,
        )
      is_emergency_token_burnt
    }
  }
}
