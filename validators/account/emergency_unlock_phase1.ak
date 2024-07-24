use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{AccountEmergencyActionPhase1Redeemer}
use aiken_virtual_dex/validators/account/emergency_unlock_phase1.{
  account_emergency_unlock_phase_1_logic,
}

validator(emergency_token: PolicyId) {
  pub fn account_emergency_unlock_phase_1(
    redeemer: AccountEmergencyActionPhase1Redeemer,
    context: ScriptContext,
  ) -> Bool {
    account_emergency_unlock_phase_1_logic(emergency_token, redeemer, context)
  }
}
