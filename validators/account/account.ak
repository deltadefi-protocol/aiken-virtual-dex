use aiken/hash.{Blake2b_224, Hash}
use aiken/pairs
use aiken/transaction.{ScriptContext, Spend, Transaction}
use aiken/transaction/credential.{Inline, Script, ScriptCredential}
use aiken_virtual_dex/types.{
  AccountAppUnlock, AccountDatum, AccountEmergencyActionPhase2Redeemer,
  AccountEmergencyUnlockPhase2, AccountRedeemer, AccountUserUnlock1,
  AccountUserUnlock2,
}
use vodka_redeemers.{withdrawal_redeemer}

validator(
  owner: ByteArray,
  user_unlock_1: Hash<Blake2b_224, Script>,
  user_unlock_2: Hash<Blake2b_224, Script>,
  app_unlock: Hash<Blake2b_224, Script>,
  emergency_unlock_phase2: Hash<Blake2b_224, Script>,
) {
  pub fn account(
    _datum: AccountDatum,
    redeemer: AccountRedeemer,
    context: ScriptContext,
  ) -> Bool {
    let ScriptContext { transaction, purpose } = context
    when redeemer is {
      AccountUserUnlock1 ->
        pairs.has_key(
          transaction.withdrawals,
          Inline(ScriptCredential(user_unlock_1)),
        )
      AccountUserUnlock2 ->
        pairs.has_key(
          transaction.withdrawals,
          Inline(ScriptCredential(user_unlock_2)),
        )
      AccountAppUnlock ->
        pairs.has_key(
          transaction.withdrawals,
          Inline(ScriptCredential(app_unlock)),
        )
      AccountEmergencyUnlockPhase2 ->
        when transaction.withdrawals is {
          [Pair(stake_cred, _)] -> {
            expect Inline(ScriptCredential(stake_script_hash)) = stake_cred
            expect Spend(_) = purpose
            expect Some(withdrawal_script_redeemer) =
              transaction.redeemers |> withdrawal_redeemer(stake_script_hash)
            expect AccountEmergencyActionPhase2Redeemer {
              owner: redeemer_owner,
            }: AccountEmergencyActionPhase2Redeemer = withdrawal_script_redeemer
            let is_withdrawal_redeemer_correct = redeemer_owner == owner
            let is_withdrawal_script_present =
              stake_script_hash == emergency_unlock_phase2
            is_withdrawal_redeemer_correct && is_withdrawal_script_present
          }
          _ -> False
        }
    }
  }
}
