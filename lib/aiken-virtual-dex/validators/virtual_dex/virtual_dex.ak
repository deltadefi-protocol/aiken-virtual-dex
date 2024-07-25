use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction.{
  Input, Output, ScriptContext, Spend, Transaction, find_input,
}
use aiken/transaction/credential.{Inline, Script, ScriptCredential}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/common.{inputs_at, only_input_datum_with, outputs_at}
use aiken_virtual_dex/types.{
  CancelOrder, EmergencyCancel, OracleDatum, TakeOrders, VirtualDexDatum,
  VirtualDexRedeemer,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use sidan_utils/extra_signatories.{key_signed}
use sidan_utils/mints.{only_minted_token}

pub fn virtual_dex_logic(
  oracle_nft: PolicyId,
  emergency_token: PolicyId,
  take_orders: Hash<Blake2b_224, Script>,
  datum: VirtualDexDatum,
  redeemer: VirtualDexRedeemer,
  context: ScriptContext,
) {
  let ScriptContext { purpose, transaction } = context

  when redeemer is {
    TakeOrders ->
      when transaction.withdrawals is {
        [Pair(stake_cred, _)] -> {
          expect Inline(ScriptCredential(stake_script_hash)) = stake_cred
          stake_script_hash == take_orders
        }
        _ -> False
      }

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
      expect OracleDatum { operation_key, .. }: OracleDatum =
        only_input_datum_with(reference_inputs, oracle_nft, "")
      let is_order_value_returned = own_input.output.value == trade_output.value
      let is_operation_key_signed = key_signed(extra_signatories, operation_key)
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
