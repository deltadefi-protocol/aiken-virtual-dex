use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{ChangeAddressDatum, ChangeAddressRedeemer}
use aiken_virtual_dex/validators/change_account.{change_account_logic}

validator(oracle_nft: PolicyId) {
  fn change_account(
    datum: ChangeAddressDatum,
    redeemer: ChangeAddressRedeemer,
    context: ScriptContext,
  ) {
    change_account_logic(oracle_nft, datum, redeemer, context)
  }
}
