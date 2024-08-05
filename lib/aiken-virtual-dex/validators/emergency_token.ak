use aiken/transaction.{Mint, ScriptContext, Transaction}
use aiken_virtual_dex/common.{check_policy_only_burn}
use aiken_virtual_dex/types.{
  AccountDatum, EBurn, EMint, EmergencyTokenMintingPolarity,
  EmergencyUnlockPhase1, EmergencyUnlockPhase2,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use sidan_utils/extra_signatories.{key_signed}
use sidan_utils/inputs.{inputs_at}
use sidan_utils/mints.{only_minted_token}
use sidan_utils/outputs.{output_inline_datum, outputs_at}
use sidan_utils/validity_range.{valid_before}

pub fn emergency_token_logic(
  redeemer: EmergencyTokenMintingPolarity,
  context: ScriptContext,
) -> Bool {
  let ScriptContext { purpose, transaction } = context
  expect Mint(current_policy) = purpose
  when redeemer is {
    EMint { current_timestamp, account_address } -> {
      let Transaction {
        inputs,
        outputs,
        mint,
        extra_signatories,
        validity_range,
        ..
      } = transaction
      expect [initiation_input] = inputs_at(inputs, account_address)
      expect EmergencyUnlockPhase1 { owner }: AccountDatum =
        output_inline_datum(initiation_input.output)
      expect [emergency_output] = outputs_at(outputs, account_address)
      expect EmergencyUnlockPhase2 { valid_since, minter }: AccountDatum =
        output_inline_datum(emergency_output)
      let is_emergency_token_name_correct =
        only_minted_token(
          mint,
          current_policy,
          get_emergency_token_name(account_address),
          1,
        )
      let is_datum_correct = owner == minter && valid_since == current_timestamp
      let is_owner_signed = key_signed(extra_signatories, owner)
      let is_time_valid = valid_before(validity_range, current_timestamp)
      is_owner_signed && is_emergency_token_name_correct && is_datum_correct && is_time_valid
    }
    EBurn -> check_policy_only_burn(transaction.mint, current_policy)
  }
}
