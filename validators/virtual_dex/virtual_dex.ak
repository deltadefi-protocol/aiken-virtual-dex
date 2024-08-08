use aiken/hash.{Blake2b_224, Hash}
use aiken/pairs
use aiken/transaction.{
  Input, Output, ScriptContext, Spend, Transaction, find_input,
}
use aiken/transaction/credential.{Inline, Script, ScriptCredential}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/types.{
  CancelOrder, DexOracleDatum, EmergencyCancel, TakeOrders, VirtualDexDatum,
  VirtualDexRedeemer,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_at, only_input_datum_with}
use vodka_mints.{only_minted_token}
use vodka_outputs.{outputs_at}

validator(
  oracle_nft: PolicyId,
  emergency_token: PolicyId,
  take_orders: Hash<Blake2b_224, Script>,
) {
  pub fn virtual_dex(
    datum: VirtualDexDatum,
    redeemer: VirtualDexRedeemer,
    context: ScriptContext,
  ) {
    let ScriptContext { purpose, transaction } = context

    when redeemer is {
      TakeOrders ->
        pairs.has_key(
          transaction.withdrawals,
          Inline(ScriptCredential(take_orders)),
        )

      CancelOrder -> {
        expect Spend(own_utxo) = purpose
        let Transaction {
          inputs,
          outputs,
          reference_inputs,
          extra_signatories,
          ..
        } = transaction
        let VirtualDexDatum { account_address, .. } = datum
        expect Some(input) = find_input(transaction.inputs, own_utxo)
        expect [own_input] = inputs_at(inputs, input.output.address)
        expect [trade_output] = outputs_at(outputs, account_address)
        expect DexOracleDatum { operation_key, .. }: DexOracleDatum =
          only_input_datum_with(reference_inputs, oracle_nft, "")
        let is_order_value_returned =
          own_input.output.value == trade_output.value
        let is_operation_key_signed =
          key_signed(extra_signatories, operation_key)
        is_order_value_returned && is_operation_key_signed
      }
      EmergencyCancel -> {
        let Transaction { mint, .. } = transaction
        let VirtualDexDatum { account_address, .. } = datum
        let is_emergency_token_burnt =
          only_minted_token(
            mint,
            emergency_token,
            get_emergency_token_name(account_address),
            -1,
          )
        is_emergency_token_burnt
      }
    }
  }
}
