use aiken/list
use aiken/pairs
use aiken/transaction.{Input, Output, ScriptContext, Transaction, WithdrawFrom}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{
  AssetName, PolicyId, Value, from_asset, from_lovelace, merge,
}
use aiken_virtual_dex/common.{
  only_input_datum_with, output_inline_datum, value_geq,
}
use aiken_virtual_dex/types.{OracleDatum, VirtualDexDatum}
use sidan_utils/address.{address_script_hash}
use sidan_utils/extra_signatories.{key_signed}

pub fn accumulate_all_to_return_value(
  long_token: (PolicyId, AssetName),
  short_token: (PolicyId, AssetName),
  inputs: List<Input>,
) -> (Bool, Option<Address>, Pairs<Address, Value>, Int) {
  list.foldr(
    inputs,
    (True, None, [], 0),
    fn(input: Input, acc: (Bool, Option<Address>, Pairs<Address, Value>, Int)) {
      when address_script_hash(input.output.address) is {
        None -> acc
        Some(_) -> {
          let current_address = input.output.address
          let is_address_valid =
            when acc.2nd is {
              None -> True
              Some(script_address) -> script_address == current_address
            }
          expect VirtualDexDatum {
            account_address,
            is_long,
            list_price_times_1mil,
            lot_size,
            extra_lovelace,
          }: VirtualDexDatum = output_inline_datum(input.output)
          let current_item = pairs.get_first(acc.3rd, account_address)
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
              |> merge(from_lovelace(extra_lovelace))
          when current_item is {
            None ->
              (
                is_address_valid,
                Some(current_address),
                acc.3rd
                  |> list.push(Pair(account_address, to_return_value)),
                acc.4th + lot_size,
              )
            Some(value) ->
              (
                is_address_valid,
                Some(current_address),
                acc.3rd
                  |> list.push(
                      Pair(account_address, merge(value, to_return_value)),
                    ),
                acc.4th + lot_size,
              )
          }
        }
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

pub fn virtual_dex_take_orders_logic(
  oracle_nft: PolicyId,
  param_long_token: (PolicyId, AssetName),
  param_short_token: (PolicyId, AssetName),
  _redeemer: Data,
  context: ScriptContext,
) -> Bool {
  let ScriptContext { purpose, transaction } = context
  expect WithdrawFrom(_) = purpose

  let Transaction { reference_inputs, inputs, outputs, .. } = transaction
  expect OracleDatum { operation_key, .. }: OracleDatum =
    only_input_datum_with(reference_inputs, oracle_nft, "")
  let (is_only_one_script_address, _, trade_payment_map, _long_token_quantity) =
    accumulate_all_to_return_value(param_long_token, param_short_token, inputs)
  let payment_values = accumuate_all_payment_value(outputs)
  let is_operation_key_signed =
    key_signed(transaction.extra_signatories, operation_key)
  // - Accumulate proceeds supposed send to order creators, check output value to them
  // 1. Look throught all inputs ->
  //       if from same address -> get (account_address, change_account_address, receive_value)
  // 2. Merge all results above with same account_address
  // 3. Check each unique account_address, if outputs to trade_account + change_account >= to_receive
  let is_token_paid_to_inidividual_maker =
    fn(payment_item) {
      let Pair(account_address, to_receive_value) = payment_item
      let maybe_account_received_value =
        pairs.get_first(payment_values, account_address)
      when maybe_account_received_value is {
        Some(account_received_value) ->
          value_geq(account_received_value, to_receive_value)
        None -> False
      }
    }
  let is_token_paid_to_makers =
    trade_payment_map
      |> list.all(is_token_paid_to_inidividual_maker)
  is_only_one_script_address && is_operation_key_signed && is_token_paid_to_makers
}
