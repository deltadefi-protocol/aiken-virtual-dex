use account/account.{account}
use aiken/transaction.{ScriptContext, Spend, Transaction}
use aiken_virtual_dex/placeholder.{
  mock_user_vkey_hex, script_hash_4_1, script_hash_4_2, script_hash_4_3,
  script_hash_4_4,
}
use aiken_virtual_dex/types.{AccountNormalDatum, AccountRedeemer}
use mocktail/virgin_output_reference.{mock_utxo_ref}

pub fn account_process(index: Int, tx: Transaction, redeemer: AccountRedeemer) {
  let output_reference = mock_utxo_ref(0, index)
  let spend_ctx =
    ScriptContext { purpose: Spend(output_reference), transaction: tx }
  account(
    mock_user_vkey_hex(),
    script_hash_4_1(),
    script_hash_4_1(),
    script_hash_4_2(),
    script_hash_4_3(),
    AccountNormalDatum,
    redeemer,
    spend_ctx,
  )
}
