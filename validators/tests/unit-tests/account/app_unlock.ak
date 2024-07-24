use aiken/transaction.{ScriptContext, WithdrawFrom}
use aiken/transaction/credential.{Inline, ScriptCredential}
use aiken/transaction/value.{from_lovelace}
use aiken_virtual_dex/placeholder.{
  mock_account_address, mock_another_account_address, mock_operation_key,
  mock_oracle_policy_id, mock_oracle_ref_input, script_hash_3_2,
}
use aiken_virtual_dex/types.{AccountAppUnlock, AccountNormalDatum}
use aiken_virtual_dex/validators/account/app_unlock.{account_app_unlock_logic}
use sidan_placeholder/builder.{
  TxTester, complete, new_tx_tester, required_signer_hash, script_withdrawal,
  tx_in, tx_in_inline_datum, tx_out, tx_out_inline_datum,
}
use sidan_placeholder/output_reference.{mock_tx_hash}
use sidan_placeholder/transaction.{add_reference_input} as sidan_transaction
use tests/unit_tests/account/account.{account_process} as taccount

type TestCase32 {
  is_operation_key_signed: Bool,
  is_value_resepnt_into_account: Bool,
  is_only_single_account: Bool,
  is_withdrawal_script_present: Bool,
}

fn base_test_case_3_2() {
  TestCase32 {
    is_operation_key_signed: True,
    is_value_resepnt_into_account: True,
    is_only_single_account: True,
    is_withdrawal_script_present: True,
  }
}

fn mock_test_case_3_2(number_of_inputs: Int, test_case: TestCase32) {
  let TestCase32 {
    is_operation_key_signed,
    is_value_resepnt_into_account,
    is_only_single_account,
    is_withdrawal_script_present,
  } = test_case

  let add_trade_account_input =
    fn(tx_tester: TxTester, index: Int) {
      tx_tester
        |> tx_in(
            index < number_of_inputs,
            mock_tx_hash(0),
            index + 1,
            from_lovelace(5_000_000),
            mock_account_address(),
          )
        |> tx_in_inline_datum(index < number_of_inputs, AccountNormalDatum)
    }

  new_tx_tester()
    |> add_trade_account_input(0)
    |> add_trade_account_input(1)
    |> add_trade_account_input(2)
    |> add_trade_account_input(3)
    |> add_trade_account_input(4)
    |> add_trade_account_input(5)
    |> add_trade_account_input(6)
    |> add_trade_account_input(7)
    |> add_trade_account_input(8)
    |> add_trade_account_input(9)
    |> add_trade_account_input(10)
    |> tx_in(
        !is_only_single_account,
        mock_tx_hash(1),
        0,
        from_lovelace(5_000_000),
        mock_another_account_address(),
      )
    |> tx_in_inline_datum(!is_only_single_account, AccountNormalDatum)
    |> tx_out(
        True,
        mock_account_address(),
        from_lovelace(5_000_000 * ( number_of_inputs - 1 )),
      )
    |> tx_out_inline_datum(True, AccountNormalDatum)
    |> tx_out(
        is_value_resepnt_into_account,
        mock_account_address(),
        from_lovelace(5_000_000 * ( number_of_inputs - 1 )),
      )
    |> tx_out_inline_datum(is_value_resepnt_into_account, AccountNormalDatum)
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> script_withdrawal(is_withdrawal_script_present, script_hash_3_2(), 0)
    |> complete()
    |> add_reference_input(True, mock_oracle_ref_input())
}

test t3_2_success() {
  let tx = mock_test_case_3_2(10, base_test_case_3_2())
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_3_2()))),
      transaction: tx,
    }
  account_process(0, tx, AccountAppUnlock) && account_app_unlock_logic(
    mock_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}

test t3_2_failed_without_operation_key_signed() {
  let tx =
    mock_test_case_3_2(
      10,
      TestCase32 { ..base_test_case_3_2(), is_operation_key_signed: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_3_2()))),
      transaction: tx,
    }
  account_process(0, tx, AccountAppUnlock) && !account_app_unlock_logic(
    mock_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}

test t3_2_failed_without_value_resepnt_into_account() {
  let tx =
    mock_test_case_3_2(
      10,
      TestCase32 {
        ..base_test_case_3_2(),
        is_value_resepnt_into_account: False,
      },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_3_2()))),
      transaction: tx,
    }
  account_process(0, tx, AccountAppUnlock) && !account_app_unlock_logic(
    mock_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}

test t3_2_failed_with_other_account_unlock_attempt() {
  let tx =
    mock_test_case_3_2(
      10,
      TestCase32 { ..base_test_case_3_2(), is_only_single_account: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_3_2()))),
      transaction: tx,
    }
  account_process(0, tx, AccountAppUnlock) && !account_app_unlock_logic(
    mock_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}

test t3_2_failed_without_withdrawal_script_present() {
  let tx =
    mock_test_case_3_2(
      10,
      TestCase32 { ..base_test_case_3_2(), is_withdrawal_script_present: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_3_2()))),
      transaction: tx,
    }
  !account_process(0, tx, AccountAppUnlock) && account_app_unlock_logic(
    mock_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}
