use aiken/transaction.{ScriptContext, Spend}
use aiken/transaction/value.{PolicyId}
use aiken_virtual_dex/common.{key_signed}
use aiken_virtual_dex/types.{
  AppRefill, ChangeAddressDatum, ChangeAddressRedeemer, OwnerWithdraw,
}

pub fn change_account_logic(
  _oracle_nft: PolicyId,
  datum: ChangeAddressDatum,
  redeemer: ChangeAddressRedeemer,
  context: ScriptContext,
) -> Bool {
  let ScriptContext { purpose, transaction } = context
  expect Spend(_) = purpose
  when redeemer is {
    OwnerWithdraw -> key_signed(transaction.extra_signatories, datum.owner)
    AppRefill -> False
  }
  // TODO
}
