use aiken/transaction.{
  InlineDatum, Input, ScriptContext, WithdrawFrom, find_input,
}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{
  AccountDatum, AccountEmergencyActionPhase1Redeemer, EmergencyUnlockPhase1,
  EmergencyUnlockPhase2,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use vodka_extra_signatories.{key_signed}
use vodka_mints.{only_minted_token}
use vodka_outputs.{outputs_at_with}
use vodka_validity_range.{valid_before}

validator(emergency_token: PolicyId) {
  pub fn account_emergency_unlock_phase_1(
    redeemer: AccountEmergencyActionPhase1Redeemer,
    context: ScriptContext,
  ) -> Bool {
    let ScriptContext { purpose, transaction } = context
    expect WithdrawFrom(_) = purpose

    let AccountEmergencyActionPhase1Redeemer {
      owner,
      own_input,
      initiate_before,
    } = redeemer
    expect Some(own_input) = find_input(transaction.inputs, own_input)
    let current_address = own_input.output.address
    expect [own_output] =
      outputs_at_with(
        transaction.outputs,
        current_address,
        emergency_token,
        get_emergency_token_name(current_address),
      )

    let is_owner_signed = key_signed(transaction.extra_signatories, owner)
    let is_emergency_token_minted =
      only_minted_token(
        transaction.mint,
        emergency_token,
        get_emergency_token_name(current_address),
        1,
      )
    let is_input_datum_correct =
      when own_input.output.datum is {
        InlineDatum(inline_datum) -> {
          expect EmergencyUnlockPhase1 { owner: owner_address }: AccountDatum =
            inline_datum
          owner_address == owner
        }
        _ -> False
      }
    let is_output_correct =
      when own_output.datum is {
        InlineDatum(inline_datum) -> {
          expect EmergencyUnlockPhase2 { valid_since, minter }: AccountDatum =
            inline_datum
          minter == owner && valid_since == initiate_before
        }
        _ -> False
      }
    let is_time_valid =
      valid_before(transaction.validity_range, initiate_before)
    is_owner_signed? && is_emergency_token_minted? && is_input_datum_correct? && is_output_correct? && is_time_valid?
  }
}
