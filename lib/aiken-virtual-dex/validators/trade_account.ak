use aiken/transaction.{ScriptContext, Spend}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/common.{all_key_signed, only_input_datum_with}
use aiken_virtual_dex/types.{
  OracleDatum, PlaceOrder, TradeAddressDatum, TradeAddressRedeemer, TradeUtxo,
  TradeWithdrawal,
}

pub fn trade_account_logic(
  oracle_nft: PolicyId,
  datum: TradeAddressDatum,
  redeemer: TradeAddressRedeemer,
  context: ScriptContext,
) -> Bool {
  let ScriptContext { purpose, transaction } = context
  expect Spend(_) = purpose
  expect OracleDatum { operation_key, .. }: OracleDatum =
    only_input_datum_with(transaction.reference_inputs, oracle_nft, "")
  when redeemer is {
    PlaceOrder -> {
      expect TradeUtxo { owner } = datum
      all_key_signed(transaction.extra_signatories, [owner, operation_key])
    }
    TradeWithdrawal -> False
  }
  // TODO
}
