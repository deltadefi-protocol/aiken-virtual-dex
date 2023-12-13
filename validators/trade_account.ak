use aiken/transaction.{ScriptContext}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{TradeAccountDatum, TradeAccountRedeemer}
use aiken_virtual_dex/validators/trade_account.{trade_account_logic}

validator(oracle_nft: PolicyId, owner: ByteArray) {
  fn trade_account(
    datum: TradeAccountDatum,
    redeemer: TradeAccountRedeemer,
    context: ScriptContext,
  ) {
    trade_account_logic(oracle_nft, owner, datum, redeemer, context)
  }
}
