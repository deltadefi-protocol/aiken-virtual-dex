use aiken/transaction.{InlineDatum, ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{
  AccountEmergencyActionPhase2Redeemer, EmergencyUnlockDatum,
}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_with}
use vodka_mints.{only_minted_token}
use vodka_validity_range.{valid_before}

validator(emergency_token: PolicyId) {
  pub fn account_emergency_unlock_phase_2(
    redeemer: AccountEmergencyActionPhase2Redeemer,
    context: ScriptContext,
  ) -> Bool {
    let transaction = context.transaction
    let AccountEmergencyActionPhase2Redeemer { owner } = redeemer
    expect [emergency_input] =
      inputs_with(transaction.inputs, emergency_token, #"")
    expect InlineDatum(raw_datum) = emergency_input.output.datum
    expect casted_datum: EmergencyUnlockDatum = raw_datum
    let EmergencyUnlockDatum { minter, minted_at } = casted_datum
    let is_minted_info_correct = minter == owner
    let is_owner_signed = key_signed(transaction.extra_signatories, owner)
    let is_emergency_token_burnt =
      only_minted_token(transaction.mint, emergency_token, #"", -1)
    let is_time_valid =
      valid_before(transaction.validity_range, minted_at + 172800)
    is_minted_info_correct? && is_owner_signed? && is_emergency_token_burnt? && is_time_valid?
    // The assertion for valid_before essentially makes the emergency unlock able to expire after 2 days
    // Since the emergency token can only be burned 1 day after minted_at, the window for the unlock is between 1 and 2 days
    // after minted_at. It is still possible to burn the emergency token, making clean up possible, but unlocking impossible.
  }
}
