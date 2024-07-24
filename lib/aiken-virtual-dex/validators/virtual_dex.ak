use aiken/list
use aiken/pairs
use aiken/transaction.{
  Input, Output, ScriptContext, Spend, Transaction, find_input,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{AssetName, PolicyId, Value, from_asset, merge}
use aiken_virtual_dex/common.{
  inputs_at, only_input_datum_with, output_inline_datum, outputs_at,
  redeemer_from, value_geq,
}
use aiken_virtual_dex/types.{
  CancelOrder, EmergencyCancel, MassTakeOrder, OracleDatum, TakeOrder,
  VirtualDexDatum, VirtualDexRedeemer,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use sidan_utils/extra_signatories.{key_signed}
use sidan_utils/mints.{only_minted_token}

pub fn accumulate_all_to_return_value(
  long_token: (PolicyId, AssetName),
  short_token: (PolicyId, AssetName),
  inputs: List<Input>,
  own_address: Address,
) -> (Pairs<Address, (Address, Value)>, Int) {
  list.foldr(
    inputs,
    ([], 0),
    fn(x: Input, acc: (Pairs<Address, (Address, Value)>, Int)) {
      let is_from_same_address = own_address == x.output.address
      when is_from_same_address is {
        True -> {
          expect VirtualDexDatum {
            trade_account_address,
            change_account_address,
            is_long,
            list_price_times_1mil,
            lot_size,
          }: VirtualDexDatum = output_inline_datum(x.output)
          let current_item = pairs.get_first(acc.1st, trade_account_address)
          let to_return_value =
            if is_long {
              from_asset(long_token.1st, long_token.2nd, lot_size)
            } else {
              from_asset(
                short_token.1st,
                short_token.2nd,
                list_price_times_1mil * lot_size / 1000000,
              )
            }
          when current_item is {
            None ->
              (
                acc.1st
                  |> list.push(
                      Pair(trade_account_address,
                      (change_account_address, to_return_value)),
                    ),
                acc.2nd + lot_size,
              )
            Some((change_account_address, value)) ->
              (
                acc.1st
                  |> list.push(
                      Pair(trade_account_address,
                      (change_account_address, merge(value, to_return_value))),
                    ),
                acc.2nd + lot_size,
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
) -> Pairs<Address, Value> {
  list.foldr(
    outputs,
    [],
    fn(x: Output, acc: Pairs<Address, Value>) {
      let this_address = x.address
      let current_item = pairs.get_first(acc, this_address)
      when current_item is {
        None -> acc |> list.push(Pair(x.address, x.value))
        Some(val) -> acc |> list.push(Pair(x.address, merge(val, x.value)))
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
          let Pair(trade_account_address,
          (change_account_address, to_receive_value)) = payment_item
          let maybe_trade_received_value =
            pairs.get_first(payment_values, trade_account_address)
          let maybe_change_received_value =
            pairs.get_first(payment_values, change_account_address)
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
