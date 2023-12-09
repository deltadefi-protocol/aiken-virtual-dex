use aiken/transaction.{InlineDatum, ScriptContext, Spend, find_input}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/common.{all_key_signed, key_signed, only_input_datum_with}
use aiken_virtual_dex/types.{
  OracleDatum, TradeAddressDatum, TradeAddressRedeemer, TradeEmergencyAction,
  TradeEmergencyDatum, TradeNormalAction,
}

pub fn trade_account_logic(
  oracle_nft: PolicyId,
  owner: ByteArray,
  _datum: TradeAddressDatum,
  redeemer: TradeAddressRedeemer,
  context: ScriptContext,
) -> Bool {
  let ScriptContext { purpose, transaction } = context
  expect Spend(_) = purpose
  expect OracleDatum { operation_key, .. }: OracleDatum =
    only_input_datum_with(transaction.reference_inputs, oracle_nft, "")
  when redeemer is {
    TradeNormalAction ->
      all_key_signed(transaction.extra_signatories, [owner, operation_key])
    TradeEmergencyAction { withdraw_output } -> {
      expect Some(input) = find_input(transaction.inputs, withdraw_output)
      expect InlineDatum(raw_datum) = input.output.datum
      expect casted_datum: TradeAddressDatum = raw_datum
      when casted_datum is {
        TradeEmergencyDatum { .. } ->
          key_signed(transaction.extra_signatories, owner)
        _ -> False
      }
    }
  }
}
