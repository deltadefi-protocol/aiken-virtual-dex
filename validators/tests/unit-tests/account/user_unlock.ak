use aiken/transaction.{ScriptContext, Spend, WithdrawFrom}
use aiken/transaction/credential.{Inline, ScriptCredential}
use aiken_virtual_dex/placeholder.{
  mock_operation_key, mock_oracle_policy_id, mock_oracle_ref_input,
  mock_user_vkey_hex, script_hash_3_1, script_hash_3_2, script_hash_3_3,
  script_hash_3_4,
}
use aiken_virtual_dex/types.{AccountNormalDatum, AccountUserUnlock}
use aiken_virtual_dex/validators/account/account.{account_logic}
use aiken_virtual_dex/validators/account/user_unlock.{account_user_unlock_logic}
use sidan_placeholder/builder.{
  complete, new_tx_tester, required_signer_hash, script_withdrawal,
}
use sidan_placeholder/output_reference.{mock_utxo_ref}
use sidan_placeholder/transaction.{add_reference_input} as sidan_transaction

type TestCase31 {
  is_owner_signed: Bool,
  is_operation_key_signed: Bool,
  is_withdrawal_script_present: Bool,
}

fn base_test_case_3_1() {
  TestCase31 {
    is_owner_signed: True,
    is_operation_key_signed: True,
    is_withdrawal_script_present: True,
  }
}

fn mock_test_case_3_1(test_case: TestCase31) {
  let TestCase31 {
    is_owner_signed,
    is_operation_key_signed,
    is_withdrawal_script_present,
  } = test_case

  new_tx_tester()
    |> required_signer_hash(is_owner_signed, mock_user_vkey_hex())
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> script_withdrawal(is_withdrawal_script_present, script_hash_3_1(), 0)
    |> complete()
    |> add_reference_input(True, mock_oracle_ref_input())
}

test t3_1_success() {
  let redeemer = AccountUserUnlock
  let output_reference = mock_utxo_ref(0, 1)

  let tx = mock_test_case_3_1(base_test_case_3_1())
  let spend_ctx =
    ScriptContext { purpose: Spend(output_reference), transaction: tx }
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_3_1()))),
      transaction: tx,
    }
  account_logic(
    mock_user_vkey_hex(),
    script_hash_3_1(),
    script_hash_3_2(),
    script_hash_3_3(),
    script_hash_3_4(),
    AccountNormalDatum,
    redeemer,
    spend_ctx,
  ) && account_user_unlock_logic(
    mock_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    withdrawal_ctx,
  )
}

test t3_1_success_mass() {
  let redeemer = AccountUserUnlock

  let tx = mock_test_case_3_1(base_test_case_3_1())

  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_3_1()))),
      transaction: tx,
    }
  let unlock_process =
    fn(index: Int) {
      let output_reference = mock_utxo_ref(0, index)
      let spend_ctx =
        ScriptContext { purpose: Spend(output_reference), transaction: tx }
      account_logic(
        mock_user_vkey_hex(),
        script_hash_3_1(),
        script_hash_3_2(),
        script_hash_3_3(),
        script_hash_3_4(),
        AccountNormalDatum,
        redeemer,
        spend_ctx,
      )
    }
  unlock_process(0) && account_user_unlock_logic(
    mock_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    withdrawal_ctx,
  )
}
