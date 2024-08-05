use aiken/transaction.{ScriptContext, Spend, Transaction}
use aiken_virtual_dex/placeholder.{
  mock_user_vkey_hex, script_hash_4_1, script_hash_4_2, script_hash_4_3,
  script_hash_4_4,
}
use aiken_virtual_dex/types.{AccountNormalDatum, AccountRedeemer}
use aiken_virtual_dex/validators/account/account.{account_logic}
use sidan_placeholder/output_reference.{mock_utxo_ref}

pub fn account_process(index: Int, tx: Transaction, redeemer: AccountRedeemer) {
  let output_reference = mock_utxo_ref(0, index)
  let spend_ctx =
    ScriptContext { purpose: Spend(output_reference), transaction: tx }
  account_logic(
    mock_user_vkey_hex(),
    script_hash_4_1(),
    script_hash_4_1(),
    script_hash_4_2(),
    script_hash_4_3(),
    script_hash_4_4(),
    AccountNormalDatum,
    redeemer,
    spend_ctx,
  )
}
