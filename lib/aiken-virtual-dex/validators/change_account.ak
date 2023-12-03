use aiken/transaction.{ScriptContext, Spend, Transaction}
use aiken/transaction/value.{PolicyId, merge}
use aiken_virtual_dex/common.{
  get_all_value_from, get_all_value_to, key_signed, only_input_datum_with,
  redeemer_from, value_geq,
}
use aiken_virtual_dex/types.{
  AppRefill, ChangeAddressDatum, ChangeAddressRedeemer, MassRefill, OracleDatum,
  OwnerWithdraw,
}

pub fn change_account_logic(
  oracle_nft: PolicyId,
  owner: ByteArray,
  _datum: ChangeAddressDatum,
  redeemer: ChangeAddressRedeemer,
  context: ScriptContext,
) -> Bool {
  let ScriptContext { purpose, transaction } = context
  let Transaction {
    extra_signatories,
    reference_inputs,
    redeemers,
    inputs,
    outputs,
    ..
  } = transaction
  expect Spend(_) = purpose
  expect OracleDatum { trade_account_address, change_account_address, .. }: OracleDatum =
    only_input_datum_with(reference_inputs, oracle_nft, "")
  when redeemer is {
    OwnerWithdraw -> key_signed(extra_signatories, owner)
    AppRefill -> {
      let input_value = get_all_value_from(inputs, change_account_address)
      let change_output_value =
        get_all_value_to(outputs, change_account_address)
      let trade_output_value = get_all_value_to(outputs, trade_account_address)
      merge(change_output_value, trade_output_value) |> value_geq(input_value)
    }
    MassRefill { refill_output } -> {
      expect Some(raw_target_redeemer) =
        redeemer_from(redeemers, inputs, refill_output, change_account_address)
      expect target_redeemer: ChangeAddressRedeemer = raw_target_redeemer
      when target_redeemer is {
        AppRefill -> True
        _ -> False
      }
    }
  }
}
