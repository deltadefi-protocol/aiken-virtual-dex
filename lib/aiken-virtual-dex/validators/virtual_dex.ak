use aiken/transaction.{ScriptContext, Spend, Transaction, find_input}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/common.{
  inputs_at, key_signed, only_input_datum_with, only_minted_token, outputs_at,
  redeemer_from,
}
use aiken_virtual_dex/types.{
  CancelOrder, EmergencyCancel, MassTakeOrder, OracleDatum, TakeOrder,
  VirtualDexDatum, VirtualDexRedeemer,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}

// pub fn valid_virtual_dex_redeemer(redeemers: Dict<ScriptPurpose, Data>) -> Bool {
//   True
// }

pub fn virtual_dex_logic(
  oracle_nft: PolicyId,
  _fee_ref_token: PolicyId,
  emergency_token: PolicyId,
  datum: VirtualDexDatum,
  redeemer: VirtualDexRedeemer,
  context: ScriptContext,
) {
  let ScriptContext { purpose, transaction } = context

  when redeemer is {
    TakeOrder { .. } -> {
      let Transaction { reference_inputs, .. } = transaction
      expect OracleDatum { .. }: OracleDatum =
        only_input_datum_with(reference_inputs, oracle_nft, "")
      expect Spend(own_utxo) = purpose
      expect Some(_own_input) = find_input(transaction.inputs, own_utxo)
      // let own_address = own_input.output.address
      // TODO
      // - Accumulate proceeds supposed send to order creators, check output value to them
      // 1. Look throught all inputs ->
      //       if from same address -> get (trade_account_address, change_account_address, receive_value)
      // 2. Merge all results above with same trade_account_address
      // 3. Check each unique trade_account_address, if outputs to trade_account + change_account >= to_receive
      True
    }
    MassTakeOrder { take_order_input } -> {
      let Transaction { inputs, redeemers, .. } = transaction
      expect Spend(own_utxo) = purpose
      expect Some(own_input) = find_input(transaction.inputs, own_utxo)
      let own_address = own_input.output.address
      expect Some(raw_target_redeemer) =
        redeemer_from(redeemers, inputs, take_order_input, own_address)
      expect target_redeemer: VirtualDexRedeemer = raw_target_redeemer
      when target_redeemer is {
        TakeOrder -> True
        _ -> False
      }
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
      let VirtualDexDatum { trade_account_address, .. } = datum
      expect Some(input) = find_input(transaction.inputs, own_utxo)
      expect [own_input] = inputs_at(inputs, input.output.address)
      expect [trade_output] = outputs_at(outputs, trade_account_address)
      expect OracleDatum { operation_key, .. }: OracleDatum =
        only_input_datum_with(reference_inputs, oracle_nft, "")
      let is_order_value_returned = own_input.output.value == trade_output.value
      let is_operation_key_signed = key_signed(extra_signatories, operation_key)
      is_order_value_returned && is_operation_key_signed
    }
    EmergencyCancel -> {
      let Transaction { mint, .. } = transaction
      let VirtualDexDatum { trade_account_address, .. } = datum
      let is_emergency_token_burnt =
        only_minted_token(
          mint,
          emergency_token,
          get_emergency_token_name(trade_account_address),
          -1,
        )
      is_emergency_token_burnt
    }
  }
}
