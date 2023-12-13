use aiken/transaction.{ScriptContext, Spend, Transaction, find_input}
use aiken/transaction/value.{PolicyId, merge}
use aiken_virtual_dex/common.{
  get_all_value_from, get_all_value_to, key_signed, only_input_datum_with,
  redeemer_from, value_geq,
}
use aiken_virtual_dex/types.{
  AppRefill, ChangeAccountDatum, ChangeAccountRedeemer, MassRefill, OracleDatum,
  OwnerWithdraw,
}
use aiken_virtual_dex/utils.{get_account_token_name}

pub fn change_account_logic(
  oracle_nft: PolicyId,
  account_number: Int,
  _datum: ChangeAccountDatum,
  redeemer: ChangeAccountRedeemer,
  context: ScriptContext,
) -> Bool {
  True
  // let ScriptContext { purpose, transaction } = context
  // let Transaction {
  //   extra_signatories,
  //   reference_inputs,
  //   redeemers,
  //   inputs,
  //   outputs,
  //   ..
  // } = transaction
  // expect Spend(own_utxo) = purpose
  // expect OracleDatum { account_info_token, .. }: OracleDatum =
  //   only_input_datum_with(reference_inputs, oracle_nft, "")
  // expect Some(own_input) = find_input(inputs, own_utxo)
  // let own_address = own_input.output.address
  // expect AccountInfoDatum { owner_pub_key, trade_account_address, .. }: AccountInfoDatum =
  //   only_input_datum_with(
  //     reference_inputs,
  //     account_info_token,
  //     get_account_token_name(account_number),
  //   )
  // when redeemer is {
  //   OwnerWithdraw -> key_signed(extra_signatories, owner_pub_key)
  //   AppRefill -> {
  //     let input_value = get_all_value_from(inputs, own_address)
  //     let change_output_value = get_all_value_to(outputs, own_address)
  //     let trade_output_value = get_all_value_to(outputs, trade_account_address)
  //     merge(change_output_value, trade_output_value) |> value_geq(input_value)
  //   }
  //   MassRefill { refill_output } -> {
  //     expect Some(raw_target_redeemer) =
  //       redeemer_from(redeemers, inputs, refill_output, own_address)
  //     expect target_redeemer: ChangeAddressRedeemer = raw_target_redeemer
  //     when target_redeemer is {
  //       AppRefill -> True
  //       _ -> False
  //     }
  //   }
  // }
}
