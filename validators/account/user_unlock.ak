use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{AccountOracleDatum}
use vodka_extra_signatories.{all_key_signed}
use vodka_inputs.{only_input_datum_with}

validator(oracle_nft: PolicyId, owner: ByteArray) {
  pub fn account_user_unlock(_redeemer: Data, context: ScriptContext) -> Bool {
    let transaction = context.transaction
    expect AccountOracleDatum { operation_key, .. }: AccountOracleDatum =
      only_input_datum_with(transaction.reference_inputs, oracle_nft, "")
    all_key_signed(transaction.extra_signatories, [owner, operation_key])
  }
}
