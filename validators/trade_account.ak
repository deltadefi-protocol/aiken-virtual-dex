use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{TradeAddressDatum, TradeAddressRedeemer}
use aiken_virtual_dex/validators/trade_account.{trade_account_logic}

validator(oracle_nft: PolicyId) {
  fn trade_account(
    datum: TradeAddressDatum,
    redeemer: TradeAddressRedeemer,
    context: ScriptContext,
  ) {
    trade_account_logic(oracle_nft, datum, redeemer, context)
  }
}
