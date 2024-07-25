use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{AssetName, PolicyId}
use aiken_virtual_dex/types.{VirtualDexRedeemer}
use aiken_virtual_dex/validators/virtual_dex/take_orders.{
  virtual_dex_take_orders_logic,
}

validator(
  oracle_nft: PolicyId,
  param_long_token: (PolicyId, AssetName),
  param_short_token: (PolicyId, AssetName),
) {
  fn virtual_dex_take_orders(
    redeemer: VirtualDexRedeemer,
    context: ScriptContext,
  ) {
    virtual_dex_take_orders_logic(
      oracle_nft,
      param_long_token,
      param_short_token,
      redeemer,
      context,
    )
  }
}
