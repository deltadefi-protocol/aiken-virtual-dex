use account/user_unlock.{account_user_unlock}
use aiken/transaction.{ScriptContext, WithdrawFrom}
use aiken/transaction/credential.{Inline, ScriptCredential}
use aiken_virtual_dex/placeholder.{
  mock_account_oracle_policy_id, mock_account_oracle_ref_input,
  mock_operation_key, mock_user_vkey_hex, script_hash_4_1,
}
use aiken_virtual_dex/types.{AccountUserUnlock1}
use sidan_placeholder/builder.{
  complete, new_tx_tester, required_signer_hash, script_withdrawal,
}
use sidan_placeholder/transaction.{add_reference_input} as sidan_transaction
use tests/unit_tests/account/account.{account_process} as taccount

type TestCase41 {
  is_owner_signed: Bool,
  is_operation_key_signed: Bool,
  is_withdrawal_script_present: Bool,
}

fn base_test_case_4_1() {
  TestCase41 {
    is_owner_signed: True,
    is_operation_key_signed: True,
    is_withdrawal_script_present: True,
  }
}

fn mock_test_case_4_1(test_case: TestCase41) {
  let TestCase41 {
    is_owner_signed,
    is_operation_key_signed,
    is_withdrawal_script_present,
  } = test_case

  new_tx_tester()
    |> required_signer_hash(is_owner_signed, mock_user_vkey_hex())
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> script_withdrawal(is_withdrawal_script_present, script_hash_4_1(), 0)
    |> complete()
    |> add_reference_input(True, mock_account_oracle_ref_input())
}

test t4_1_success() {
  let redeemer = AccountUserUnlock1
  let tx = mock_test_case_4_1(base_test_case_4_1())
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_1()))),
      transaction: tx,
    }
  account_process(1, tx, redeemer) && account_user_unlock(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    withdrawal_ctx,
  )
}

test t4_1_success_mass() {
  let redeemer = AccountUserUnlock1

  // TODO: add tx in according to index
  let tx = mock_test_case_4_1(base_test_case_4_1())

  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_1()))),
      transaction: tx,
    }
  let unlock_process =
    fn(index: Int) { account_process(index, tx, redeemer) }
  unlock_process(0) && unlock_process(1) && unlock_process(2) && account_user_unlock(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    withdrawal_ctx,
  )
}

test t4_1_fail_without_owner_signed() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_4_1(
      TestCase41 { ..base_test_case_4_1(), is_owner_signed: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_1()))),
      transaction: tx,
    }
  account_process(1, tx, redeemer) && !account_user_unlock(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    withdrawal_ctx,
  )
}

test t4_1_fail_without_app_signed() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_4_1(
      TestCase41 { ..base_test_case_4_1(), is_operation_key_signed: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_1()))),
      transaction: tx,
    }
  account_process(1, tx, redeemer) && !account_user_unlock(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    withdrawal_ctx,
  )
}

test t4_1_fail_without_withdrawal_script_present() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_4_1(
      TestCase41 { ..base_test_case_4_1(), is_withdrawal_script_present: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_1()))),
      transaction: tx,
    }
  !account_process(1, tx, redeemer) && account_user_unlock(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    withdrawal_ctx,
  )
}
