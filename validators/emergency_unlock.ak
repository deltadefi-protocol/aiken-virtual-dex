use aiken_virtual_dex/types.{AccountOracleDatum, EmergencyUnlockDatum}
use cardano/assets.{PolicyId}
use cardano/transaction.{OutputReference, Transaction}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_with_policy, only_input_datum_with}
use vodka_mints.{only_minted_token}
use vodka_outputs.{output_inline_datum}
use vodka_validity_range.{valid_after}
use vodka_value.{value_policy_info}

validator emergency_unlock(oracle_nft: PolicyId) {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction {
      reference_inputs,
      inputs,
      extra_signatories,
      validity_range,
      mint,
      ..
    } = tx
    expect AccountOracleDatum { emergency_token, operation_key, .. }: AccountOracleDatum =
      only_input_datum_with(reference_inputs, oracle_nft, "")
    let emergency_inputs = inputs_with_policy(inputs, emergency_token)
    when emergency_inputs is {
      [emergency_input] -> {
        let emergency_datum = output_inline_datum(emergency_input.output)
        let emergency_token_info =
          value_policy_info(emergency_input.output.value, emergency_token)
        when emergency_token_info is {
          Some((_, asset_name, _)) ->
            if emergency_datum is EmergencyUnlockDatum {
              // If more than 2 days has passed since the emergency unlock, allow
              // the operation key to clean up expired emergency unlocks.
              if
              valid_after(
                validity_range,
                emergency_datum.minted_at + 172_800_001,
              ){
              
                key_signed(extra_signatories, operation_key)
              } else {
                let is_emergency_token_burnt =
                  only_minted_token(mint, emergency_token, asset_name, -1)
                key_signed(extra_signatories, asset_name) && is_emergency_token_burnt
              }
            } else {
              key_signed(extra_signatories, operation_key)
            }

          None -> key_signed(extra_signatories, operation_key)
        }
      }
      _ -> key_signed(extra_signatories, operation_key)
    }
  }

  else(_) {
    fail
  }
}
