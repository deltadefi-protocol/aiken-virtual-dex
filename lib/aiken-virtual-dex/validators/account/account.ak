use aiken/hash.{Blake2b_224, Hash}
use aiken/pairs
use aiken/transaction.{ScriptContext, Spend, Transaction}
use aiken/transaction/credential.{Inline, Script, ScriptCredential}
use aiken_virtual_dex/types.{
  AccountAppUnlock, AccountDatum, AccountEmergencyActionPhase1Redeemer,
  AccountEmergencyActionPhase2Redeemer, AccountEmergencyUnlockPhase1,
  AccountEmergencyUnlockPhase2, AccountRedeemer, AccountUserUnlock,
}
use sidan_utils/redeemers.{withdrawal_redeemer}

pub fn account_logic(
  owner: ByteArray,
  user_unlock: Hash<Blake2b_224, Script>,
  app_unlock: Hash<Blake2b_224, Script>,
  emergency_unlock_phase1: Hash<Blake2b_224, Script>,
  emergency_unlock_phase2: Hash<Blake2b_224, Script>,
  _datum: AccountDatum,
  redeemer: AccountRedeemer,
  context: ScriptContext,
) -> Bool {
  let ScriptContext { transaction, purpose } = context
  when redeemer is {
    AccountUserUnlock ->
      pairs.has_key(
        transaction.withdrawals,
        Inline(ScriptCredential(user_unlock)),
      )
    AccountAppUnlock ->
      pairs.has_key(
        transaction.withdrawals,
        Inline(ScriptCredential(app_unlock)),
      )
    AccountEmergencyUnlockPhase1 ->
      when transaction.withdrawals is {
        [Pair(stake_cred, _)] -> {
          expect Inline(ScriptCredential(stake_script_hash)) = stake_cred
          expect Spend(own_utxo) = purpose
          expect Some(withdrawal_script_redeemer) =
            transaction.redeemers |> withdrawal_redeemer(stake_script_hash)
          expect AccountEmergencyActionPhase1Redeemer {
            owner: redeemer_owner,
            own_input: redeemer_own_input,
            ..
          }: AccountEmergencyActionPhase1Redeemer = withdrawal_script_redeemer
          let is_withdrawal_redeemer_correct =
            redeemer_owner == owner && redeemer_own_input == own_utxo
          let is_withdrawal_script_present =
            stake_script_hash == emergency_unlock_phase1
          is_withdrawal_redeemer_correct && is_withdrawal_script_present
        }
        _ -> False
      }
    AccountEmergencyUnlockPhase2 ->
      when transaction.withdrawals is {
        [Pair(stake_cred, _)] -> {
          expect Inline(ScriptCredential(stake_script_hash)) = stake_cred
          expect Spend(own_utxo) = purpose
          expect Some(withdrawal_script_redeemer) =
            transaction.redeemers |> withdrawal_redeemer(stake_script_hash)
          expect AccountEmergencyActionPhase2Redeemer {
            owner: redeemer_owner,
            own_input: redeemer_own_input,
            ..
          }: AccountEmergencyActionPhase2Redeemer = withdrawal_script_redeemer
          let is_withdrawal_redeemer_correct =
            redeemer_owner == owner && redeemer_own_input == own_utxo
          let is_withdrawal_script_present =
            stake_script_hash == emergency_unlock_phase2
          is_withdrawal_redeemer_correct && is_withdrawal_script_present
        }

        _ -> False
      }
  }
}
