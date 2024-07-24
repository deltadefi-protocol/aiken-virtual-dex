use aiken/hash.{Blake2b_224, Hash}
use aiken/pairs.{find_first}
use aiken/transaction.{ScriptContext}
use aiken/transaction/credential.{Inline, Script, ScriptCredential}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{TradeAccountDatum}

pub type AccountRedeemer {
  AccountUserUnlock
  AccountAppUnlock
  AccountEmergencyUnlockPhase1
  AccountEmergencyUnlockPhase2
}

pub type AccountDatum {
  NormalDatum
  EmergencyUnlockPhase1 { owner: ByteArray }
  EmergencyUnlockPhase2 { valid_since: Int, minter: ByteArray }
}

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
  when redeemer is {
    AccountUserUnlock -> {
      expect [Pair(stake_cred, _)] = context.transaction.withdrawals
      expect Inline(ScriptCredential(stake_script_hash)) = stake_cred
      stake_script_hash == user_unlock
    }
    _ -> False
  }
}
