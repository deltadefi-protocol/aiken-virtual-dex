use aiken/transaction.{Mint, ScriptContext, Transaction}
use aiken/transaction/credential.{Address}
use aiken_virtual_dex/types.{
  EBurn, EMint, EmergencyTokenMintingPolarity, EmergencyUnlockDatum,
}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_at_with}
use vodka_mints.{only_minted_token}
use vodka_outputs.{output_inline_datum, outputs_at_with}
use vodka_validity_range.{valid_after}

validator(emergency_unlock_address: Address) {
  pub fn emergency_token(
    redeemer: EmergencyTokenMintingPolarity,
    context: ScriptContext,
  ) -> Bool {
    let ScriptContext { purpose, transaction } = context
    expect Mint(current_policy) = purpose
    when redeemer is {
      EMint { current_timestamp } -> {
        let Transaction { outputs, mint, extra_signatories, validity_range, .. } =
          transaction
        expect [emergency_output] =
          outputs_at_with(
            outputs,
            emergency_unlock_address,
            current_policy,
            #"",
          )
        expect EmergencyUnlockDatum { minter, minted_at } =
          output_inline_datum(emergency_output)
        let is_emergency_token_name_correct =
          only_minted_token(mint, current_policy, #"", 1)
        let is_datum_correct = minted_at == current_timestamp
        let is_owner_signed = key_signed(extra_signatories, minter)
        // It should be that the token is guaranteed to be minted after the current timestamp
        let is_time_valid = valid_after(validity_range, current_timestamp)
        is_owner_signed? && is_emergency_token_name_correct? && is_datum_correct? && is_time_valid?
      }
      EBurn -> {
        let Transaction { inputs, validity_range, extra_signatories, mint, .. } =
          transaction
        expect [initiation_input] =
          inputs_at_with(inputs, emergency_unlock_address, current_policy, #"")
        expect EmergencyUnlockDatum { minted_at, minter } =
          output_inline_datum(initiation_input.output)
        let is_owner_signed = key_signed(extra_signatories, minter)
        // Ensure that the token can only be burned one day after the minting timestamp
        let is_time_valid =
          if valid_after(validity_range, minted_at + 172800) {
            // Allow anyone to burn after emergency unlock expiry
            True
          } else if valid_after(validity_range, minted_at + 86400) {
            is_owner_signed
          } else {
            False
          }
        let is_only_burned = only_minted_token(mint, current_policy, #"", -1)
        is_time_valid? && is_only_burned?
      }
    }
  }
}
