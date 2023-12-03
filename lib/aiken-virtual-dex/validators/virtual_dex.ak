use aiken/dict.{Dict}
use aiken/list
use aiken/transaction.{
  InlineDatum, ScriptContext, ScriptPurpose, Spend, Transaction,
}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/common.{inputs_at, inputs_with}
use aiken_virtual_dex/types.{
  CancelOrder, MassTakeOrder, OracleDatum, TakeOrder, VirtualDexDatum,
  VirtualDexRedeemer,
}

pub fn valid_virtual_dex_redeemer(redeemers: Dict<ScriptPurpose, Data>) -> Bool {
  True
}

pub fn virtual_dex_logic(
  oracle_nft: PolicyId,
  datum: VirtualDexDatum,
  redeemer: VirtualDexRedeemer,
  context: ScriptContext,
) {
  let ScriptContext { purpose, transaction } = context
  expect Spend(_) = purpose
  let Transaction { inputs, reference_inputs, redeemers, .. } = transaction
  expect [oracle_input] = inputs_with(reference_inputs, oracle_nft, "")
  expect InlineDatum(raw_oracle_datum) = oracle_input.output.datum
  expect OracleDatum { min_fee, virtual_dex_address, .. }: OracleDatum =
    raw_oracle_datum

  when redeemer is {
    MassTakeOrder { .. } ->
      // at least one redeemer is TakeOrder
      True
    // expect Some(raw_redeemer) =
    //   dict.get(redeemers, Spend(content_input.output_reference))
    // expect parsed_redeemer: ContentRegistryRedeemer = raw_redeemer
    // when parsed_redeemer is {
    //   CreateContent { content_hash: _, owner: _ } -> True
    //   _ -> False
    // }
    TakeOrder -> True

    // for each script inputs, calculate the total should pay amount
    CancelOrder -> True
  }
}
