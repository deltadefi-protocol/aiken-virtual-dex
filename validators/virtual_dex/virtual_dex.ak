use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction.{ScriptContext}
use aiken/transaction/credential.{Script}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{VirtualDexDatum, VirtualDexRedeemer}
use aiken_virtual_dex/validators/virtual_dex/virtual_dex.{virtual_dex_logic}

validator(
  oracle_nft: PolicyId,
  emergency_token: PolicyId,
  take_orders: Hash<Blake2b_224, Script>,
) {
  fn virtual_dex(
    datum: VirtualDexDatum,
    redeemer: VirtualDexRedeemer,
    context: ScriptContext,
  ) {
    virtual_dex_logic(
      oracle_nft,
      emergency_token,
      take_orders,
      datum,
      redeemer,
      context,
    )
  }
}
