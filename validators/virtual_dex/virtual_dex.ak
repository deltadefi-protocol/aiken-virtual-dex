use aiken/collection/pairs
use aiken/crypto.{ScriptHash}
use aiken_virtual_dex/types.{
  CancelOrder, DexOracleDatum, EmergencyCancel, TakeOrders, VirtualDexDatum,
  VirtualDexRedeemer,
}
use cardano/address.{Script}
use cardano/assets.{PolicyId}
use cardano/transaction.{Input,
  Output, OutputReference, Transaction, find_input}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_at, only_input_datum_with}
use vodka_mints.{only_minted_token}
use vodka_outputs.{outputs_at}

validator virtual_dex(
  oracle_nft: PolicyId,
  emergency_token: PolicyId,
  take_orders: ScriptHash,
) {
  spend(
    datum_opt: Option<VirtualDexDatum>,
    redeemer: VirtualDexRedeemer,
    input: OutputReference,
    tx: Transaction,
  ) {
    when redeemer is {
      TakeOrders -> pairs.has_key(tx.withdrawals, Script(take_orders))
      CancelOrder -> {
        let Transaction {
          inputs,
          outputs,
          reference_inputs,
          extra_signatories,
          ..
        } = tx
        expect Some(datum) = datum_opt
        let VirtualDexDatum { account_address, .. } = datum
        expect Some(input) = find_input(inputs, input)
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
        let Transaction { mint, .. } = tx
        expect Some(datum) = datum_opt
        let VirtualDexDatum { owner, .. } = datum
        let is_emergency_token_burnt =
          only_minted_token(mint, emergency_token, owner, -1)
        let is_owner_signed = key_signed(tx.extra_signatories, owner)
        is_emergency_token_burnt? && is_owner_signed?
      }
    }
  }

  else(_) {
    fail
  }
}
