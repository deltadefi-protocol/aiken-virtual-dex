use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction.{ScriptContext}
use aiken/transaction/credential.{Script}
use aiken_virtual_dex/types.{AccountDatum, AccountRedeemer}
use aiken_virtual_dex/validators/account/account.{account_logic}

validator(
  owner: ByteArray,
  user_unlock: Hash<Blake2b_224, Script>,
  app_unlock: Hash<Blake2b_224, Script>,
  emergency_unlock_phase1: Hash<Blake2b_224, Script>,
  emergency_unlock_phase2: Hash<Blake2b_224, Script>,
) {
  fn account(
    datum: AccountDatum,
    redeemer: AccountRedeemer,
    context: ScriptContext,
  ) {
    account_logic(
      owner,
      user_unlock,
      app_unlock,
      emergency_unlock_phase1,
      emergency_unlock_phase2,
      datum,
      redeemer,
      context,
    )
  }
}
