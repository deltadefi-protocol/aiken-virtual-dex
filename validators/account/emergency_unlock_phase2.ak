use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{AccountEmergencyActionPhase2Redeemer}
use aiken_virtual_dex/validators/account/emergency_unlock_phase2.{
  account_emergency_unlock_phase_2_logic,
}

validator(emergency_token: PolicyId) {
  pub fn account_emergency_unlock_phase_2(
    redeemer: AccountEmergencyActionPhase2Redeemer,
    context: ScriptContext,
  ) -> Bool {
    account_emergency_unlock_phase_2_logic(emergency_token, redeemer, context)
  }
}
