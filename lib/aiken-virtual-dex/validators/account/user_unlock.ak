use aiken/transaction.{ScriptContext, WithdrawFrom}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/common.{all_key_signed, only_input_datum_with}
use aiken_virtual_dex/types.{OracleDatum}

pub fn account_user_unlock_logic(
  oracle_nft: PolicyId,
  owner: ByteArray,
  _redeemer: Void,
  context: ScriptContext,
) -> Bool {
  let ScriptContext { purpose, transaction } = context
  expect WithdrawFrom(_) = purpose
  expect OracleDatum { operation_key, .. }: OracleDatum =
    only_input_datum_with(transaction.reference_inputs, oracle_nft, "")
  all_key_signed(transaction.extra_signatories, [owner, operation_key])
}
