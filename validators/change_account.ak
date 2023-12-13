use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{ChangeAccountDatum, ChangeAccountRedeemer}
use aiken_virtual_dex/validators/change_account.{change_account_logic}

validator(oracle_nft: PolicyId, account_number: Int) {
  fn change_account(
    datum: ChangeAccountDatum,
    redeemer: ChangeAccountRedeemer,
    context: ScriptContext,
  ) {
    change_account_logic(oracle_nft, account_number, datum, redeemer, context)
  }
}
