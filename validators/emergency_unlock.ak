use aiken/transaction.{ScriptContext, Transaction}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{AccountOracleDatum, EmergencyUnlockDatum}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_with, only_input_datum_with}
use vodka_outputs.{output_inline_datum}

validator(oracle_nft: PolicyId) {
  pub fn emergency_unlock(_redeemer: Data, context: ScriptContext) -> Bool {
    let Transaction { reference_inputs, inputs, extra_signatories, .. } =
      context.transaction
    expect AccountOracleDatum { emergency_token, operation_key, .. }: AccountOracleDatum =
      only_input_datum_with(reference_inputs, oracle_nft, "")
    let emergency_inputs = inputs_with(inputs, emergency_token, #"")
    when emergency_inputs is {
      [emergency_input] -> {
        let output_inline_datum = output_inline_datum(emergency_input.output)
        if output_inline_datum is EmergencyUnlockDatum {
          key_signed(extra_signatories, output_inline_datum.minter)
        } else {
          key_signed(extra_signatories, operation_key)
        }
      }
      _other -> key_signed(extra_signatories, operation_key)
    }
  }
}
