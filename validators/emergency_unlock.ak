use aiken/transaction.{ScriptContext, Transaction}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{AccountOracleDatum, EmergencyUnlockDatum}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_with, only_input_datum_with}
use vodka_mints.{only_minted_token}
use vodka_outputs.{output_inline_datum}
use vodka_validity_range.{valid_after}

validator(oracle_nft: PolicyId) {
  pub fn emergency_unlock(
    _datum: Data,
    _redeemer: Data,
    context: ScriptContext,
  ) -> Bool {
    let Transaction {
      reference_inputs,
      inputs,
      extra_signatories,
      validity_range,
      mint,
      ..
    } = context.transaction
    expect AccountOracleDatum { emergency_token, operation_key, .. }: AccountOracleDatum =
      only_input_datum_with(reference_inputs, oracle_nft, "")
    let emergency_inputs = inputs_with(inputs, emergency_token, #"")
    when emergency_inputs is {
      [emergency_input] -> {
        let is_emergency_token_burnt =
          only_minted_token(mint, emergency_token, #"", -1)
        let emergency_datum = output_inline_datum(emergency_input.output)
        if emergency_datum is EmergencyUnlockDatum {
          // If more than 2 days has passed since the emergency unlock, allow
          // the operation key to clean up expired emergency unlocks.
          if
          valid_after(validity_range, emergency_datum.minted_at + 172_800_001){
          
            key_signed(extra_signatories, operation_key)
          } else {
            key_signed(extra_signatories, emergency_datum.minter) && is_emergency_token_burnt
          }
        } else {
          key_signed(extra_signatories, operation_key)
        }
      }
      _ -> key_signed(extra_signatories, operation_key)
    }
  }
}
