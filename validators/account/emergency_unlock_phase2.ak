use aiken/transaction.{InlineDatum, ScriptContext, WithdrawFrom, find_input}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{
  AccountDatum, AccountEmergencyActionPhase2Redeemer, EmergencyUnlockPhase2,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use vodka_extra_signatories.{key_signed}
use vodka_mints.{only_minted_token}
use vodka_validity_range.{valid_after}

validator(emergency_token: PolicyId) {
  pub fn account_emergency_unlock_phase_2(
    redeemer: AccountEmergencyActionPhase2Redeemer,
    context: ScriptContext,
  ) -> Bool {
    let ScriptContext { purpose, transaction } = context
    let AccountEmergencyActionPhase2Redeemer {
      owner,
      own_input,
      withdraw_output,
    } = redeemer
    expect WithdrawFrom(_) = purpose
    expect Some(input) = find_input(transaction.inputs, withdraw_output)
    expect Some(own_input) = find_input(transaction.inputs, own_input)
    expect InlineDatum(raw_datum) = input.output.datum
    expect casted_datum: AccountDatum = raw_datum
    when casted_datum is {
      EmergencyUnlockPhase2 { valid_since, minter } -> {
        let is_minted_info_correct = minter == owner
        let is_owner_signed = key_signed(transaction.extra_signatories, owner)
        let is_time_valid = valid_after(transaction.validity_range, valid_since)
        let is_emergency_token_burnt =
          only_minted_token(
            transaction.mint,
            emergency_token,
            get_emergency_token_name(own_input.output.address),
            -1,
          )
        is_minted_info_correct? && is_owner_signed? && is_time_valid? && is_emergency_token_burnt?
      }
      _ -> False
    }
  }
}
