use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/validators/account/app_unlock.{account_app_unlock_logic}

validator(oracle_nft: PolicyId) {
  fn app_unlock(redeemer: Data, context: ScriptContext) -> Bool {
    account_app_unlock_logic(oracle_nft, redeemer, context)
  }
}
