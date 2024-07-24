use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/validators/account/user_unlock.{account_user_unlock_logic}

validator(oracle_nft: PolicyId, owner: ByteArray) {
  pub fn user_unlock(redeemer: Data, context: ScriptContext) -> Bool {
    account_user_unlock_logic(oracle_nft, owner, redeemer, context)
  }
}
