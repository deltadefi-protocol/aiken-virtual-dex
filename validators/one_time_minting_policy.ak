use aiken/transaction.{OutputReference, ScriptContext}
use aiken_virtual_dex/types.{MintPolarity}
use aiken_virtual_dex/validators/one_time_minting_policy.{
  one_time_minting_policy_logic,
}

validator(utxo_ref: OutputReference) {
  fn one_time_minting_policy(
    redeemer: MintPolarity,
    context: ScriptContext,
  ) -> Bool {
    one_time_minting_policy_logic(utxo_ref, redeemer, context)
  }
}
