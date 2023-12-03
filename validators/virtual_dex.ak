use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{VirtualDexDatum, VirtualDexRedeemer}
use aiken_virtual_dex/validators/virtual_dex.{virtual_dex_logic}

validator(oracle_nft: PolicyId) {
  fn virtual_dex(
    datum: VirtualDexDatum,
    redeemer: VirtualDexRedeemer,
    context: ScriptContext,
  ) {
    virtual_dex_logic(oracle_nft, datum, redeemer, context)
  }
}
