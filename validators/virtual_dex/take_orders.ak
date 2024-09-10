use aiken/collection/list
use aiken/collection/pairs
use aiken_virtual_dex/types.{DexOracleDatum, VirtualDexDatum}
use cardano/address.{Address, Credential}
use cardano/assets.{AssetName,
  PolicyId, Value, from_asset, from_lovelace, merge}
use cardano/transaction.{Input, Output, Transaction}
use cardano/certificate.{Certificate}
use vodka_address.{address_script_hash}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{only_input_datum_with}
use vodka_outputs.{output_inline_datum}
use vodka_value.{value_geq} as sidan_value

validator virtual_dex_take_orders(
  oracle_nft: PolicyId,
  param_long_token: (PolicyId, AssetName),
  param_short_token: (PolicyId, AssetName),
) {
  withdraw(_redeemer: Data, _credential: Credential, tx: Transaction) {
    let Transaction { reference_inputs, inputs, outputs, .. } = tx
    expect DexOracleDatum { operation_key, dex_address, .. }: DexOracleDatum =
      only_input_datum_with(reference_inputs, oracle_nft, "")
    let (trade_payment_map, _long_token_quantity) =
      accumulate_all_to_return_value(
        param_long_token,
        param_short_token,
        inputs,
        dex_address,
      )
    let payment_values = accumuate_all_payment_value(outputs)
    let is_operation_key_signed =
      key_signed(tx.extra_signatories, operation_key)
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
    is_operation_key_signed && is_token_paid_to_makers
  }

  publish(_redeemer: Data, _certificate: Certificate, tx: Transaction) {
    let Transaction { reference_inputs, .. } = tx
    expect DexOracleDatum { operation_key, .. }: DexOracleDatum =
      only_input_datum_with(reference_inputs, oracle_nft, "")
    key_signed(tx.extra_signatories, operation_key)
  }

  else(_) {
    fail
  }
}

pub fn accumulate_all_to_return_value(
  long_token: (PolicyId, AssetName),
  short_token: (PolicyId, AssetName),
  inputs: List<Input>,
  dex_address: Address,
) -> (Pairs<Address, Value>, Int) {
  list.foldr(
    inputs,
    ([], 0),
    fn(input: Input, acc: (Pairs<Address, Value>, Int)) {
      when address_script_hash(input.output.address) is {
        None -> acc
        Some(_) -> {
          let current_address = input.output.address
          if current_address != dex_address {
            acc
          } else {
            expect VirtualDexDatum {
              account_address,
              is_long,
              list_price_times_1mil,
              lot_size,
              extra_lovelace,
            }: VirtualDexDatum = output_inline_datum(input.output)
            let current_item = pairs.get_first(acc.1st, account_address)
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
                  acc.1st
                    |> list.push(Pair(account_address, to_return_value)),
                  acc.2nd + lot_size,
                )
              Some(value) ->
                (
                  acc.1st
                    |> list.push(
                        Pair(account_address, merge(value, to_return_value)),
                      ),
                  acc.2nd + lot_size,
                )
            }
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
