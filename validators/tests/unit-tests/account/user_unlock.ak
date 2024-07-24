use aiken/transaction.{ScriptContext, Spend, Transaction, placeholder}
use aiken_virtual_dex/placeholder.{
  mock_operation_key, mock_oracle_ref_input, mock_user_vkey_hex,
}
use aiken_virtual_dex/validators/account/account.{
  AccountUserUnlock, account_logic,
}
use sidan_placeholder/output_reference.{mock_utxo_ref}

type TestCase31 {
  is_owner_signed: Bool,
  is_operation_key_signed: Bool,
}

fn base_test_case_3_1() {
  TestCase31 { is_owner_signed: True, is_operation_key_signed: True }
}

fn mock_test_case_3_1(test_case: TestCase31) {
  let TestCase31 { is_owner_signed, is_operation_key_signed } = test_case
  let extra_signatories =
    when (is_owner_signed, is_operation_key_signed) is {
      (True, True) ->
        [mock_user_vkey_hex(), mock_operation_key()]
      (True, False) ->
        [mock_user_vkey_hex()]
      (False, True) ->
        [mock_operation_key()]
      (False, False) ->
        []
    }
  Transaction {
    ..placeholder(),
    extra_signatories: extra_signatories,
    reference_inputs: [mock_oracle_ref_input()],
  }
}

test t3_1_success() {
  let redeemer = AccountUserUnlock
  let output_reference = mock_utxo_ref(0, 1)

  let tx = mock_test_case_3_1(base_test_case_3_1())
  let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
  True
  // account_logic(redeemer, ctx)
}
