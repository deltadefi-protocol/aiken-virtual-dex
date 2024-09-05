use account/account
use account/user_unlock
use aiken_virtual_dex/placeholder.{
  mock_account_oracle_policy_id, mock_account_oracle_ref_input,
  mock_emergency_token, mock_operation_key, mock_user_vkey_hex, script_hash_4_1,
  script_hash_4_2,
}
use aiken_virtual_dex/types.{AccountDatum, AccountRedeemer, AccountUserUnlock1}
use cardano/address.{Script}
use cardano/transaction.{Transaction}
use mocktail.{
  add_reference_input, complete, mocktail_tx, required_signer_hash,
  script_withdrawal,
}
use mocktail/virgin_output_reference.{mock_utxo_ref}

fn account_process(index: Int, tx: Transaction, redeemer: AccountRedeemer) {
  let input = mock_utxo_ref(0, index)
  account.account.spend(
    mock_user_vkey_hex(),
    script_hash_4_1(),
    script_hash_4_1(),
    script_hash_4_2(),
    mock_emergency_token(),
    Some(AccountDatum),
    redeemer,
    input,
    tx,
  )
}

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

  mocktail_tx()
    |> required_signer_hash(is_owner_signed, mock_user_vkey_hex())
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> script_withdrawal(is_withdrawal_script_present, script_hash_4_1(), 0)
    |> complete()
    |> add_reference_input(True, mock_account_oracle_ref_input())
}

test t4_1_success() {
  let redeemer = AccountUserUnlock1
  let tx = mock_test_case_4_1(base_test_case_4_1())
  account_process(1, tx, redeemer) && user_unlock.account_user_unlock.withdraw(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    Script(script_hash_4_1()),
    tx,
  )
}

test t4_1_success_mass() {
  let redeemer = AccountUserUnlock1
  // TODO: add tx in according to index
  let tx = mock_test_case_4_1(base_test_case_4_1())

  let unlock_process =
    fn(index: Int) { account_process(index, tx, redeemer) }
  unlock_process(0) && unlock_process(1) && unlock_process(2) && user_unlock.account_user_unlock.withdraw(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    Script(script_hash_4_1()),
    tx,
  )
}

test t4_1_fail_without_owner_signed() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_4_1(
      TestCase41 { ..base_test_case_4_1(), is_owner_signed: False },
    )
  account_process(1, tx, redeemer) && !user_unlock.account_user_unlock.withdraw(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    Script(script_hash_4_1()),
    tx,
  )
}

test t4_1_fail_without_app_signed() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_4_1(
      TestCase41 { ..base_test_case_4_1(), is_operation_key_signed: False },
    )
  account_process(1, tx, redeemer) && !user_unlock.account_user_unlock.withdraw(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    Script(script_hash_4_1()),
    tx,
  )
}

test t4_1_fail_without_withdrawal_script_present() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_4_1(
      TestCase41 { ..base_test_case_4_1(), is_withdrawal_script_present: False },
    )
  !account_process(1, tx, redeemer) && user_unlock.account_user_unlock.withdraw(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    Script(script_hash_4_1()),
    tx,
  )
}
