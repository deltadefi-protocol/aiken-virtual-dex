use aiken_virtual_dex/types.{
  EBurn, EMint, EmergencyTokenMintingPolarity, EmergencyUnlockDatum,
}
use cardano/address.{Address}
use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_at_with_policy}
use vodka_mints.{only_minted_token}
use vodka_outputs.{output_inline_datum, outputs_at_with}
use vodka_validity_range.{valid_after, valid_before}
use vodka_value.{value_policy_info}

validator emergency_token(emergency_unlock_address: Address) {
  mint(
    redeemer: EmergencyTokenMintingPolarity,
    policy_id: PolicyId,
    tx: Transaction,
  ) {
    when redeemer is {
      EMint { minter } -> {
        let Transaction { outputs, mint, extra_signatories, validity_range, .. } =
          tx
        expect [emergency_output] =
          outputs_at_with(outputs, emergency_unlock_address, policy_id, minter)
        expect EmergencyUnlockDatum { minted_at } =
          output_inline_datum(emergency_output)
        let is_emergency_token_minted =
          only_minted_token(mint, policy_id, #"", 1)
        let is_owner_signed = key_signed(extra_signatories, minter)
        // It should be that the token is guaranteed to be minted before the current timestamp
        let is_time_valid = valid_before(validity_range, minted_at)
        is_owner_signed? && is_emergency_token_minted? && is_time_valid?
      }
      EBurn -> {
        let Transaction { inputs, validity_range, extra_signatories, mint, .. } =
          tx
        expect [emergency_input] =
          inputs_at_with_policy(inputs, emergency_unlock_address, policy_id)
        expect EmergencyUnlockDatum { minted_at } =
          output_inline_datum(emergency_input.output)
        expect Some((_, asset_name, _)) =
          value_policy_info(emergency_input.output.value, policy_id)
        let is_owner_signed = key_signed(extra_signatories, asset_name)
        // Ensure that the token can only be burned one day after the minting timestamp
        let is_time_valid =
          if valid_after(validity_range, minted_at + 172_800_000) {
            // Allow anyone to burn after emergency unlock expiry
            True
          } else if valid_after(validity_range, minted_at + 86_400_000) {
            is_owner_signed
          } else {
            False
          }
        let is_only_burned = only_minted_token(mint, policy_id, #"", -1)
        is_time_valid? && is_only_burned?
      }
    }
  }

  else(_) {
    fail
  }
}
