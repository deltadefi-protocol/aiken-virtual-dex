use account/app_unlock.{account_app_unlock}
use aiken/transaction.{ScriptContext, WithdrawFrom}
use aiken/transaction/credential.{Inline, ScriptCredential}
use aiken/transaction/value.{from_lovelace}
use aiken_virtual_dex/placeholder.{
  mock_account_address, mock_account_oracle_policy_id,
  mock_account_oracle_ref_input, mock_another_account_address,
  mock_operation_key, script_hash_4_2,
}
use aiken_virtual_dex/types.{AccountAppUnlock, AccountDatum}
use mocktail.{
  MocktailTx, add_reference_input, complete, mocktail_tx, required_signer_hash,
  script_withdrawal, tx_in, tx_in_inline_datum, tx_out, tx_out_inline_datum,
}
use mocktail/virgin_output_reference.{mock_tx_hash}
use tests/unit_tests/account/account.{account_process} as taccount

type TestCase42 {
  is_operation_key_signed: Bool,
  is_value_resepnt_into_account: Bool,
  is_only_single_account: Bool,
  is_withdrawal_script_present: Bool,
}

fn base_test_case_4_2() {
  TestCase42 {
    is_operation_key_signed: True,
    is_value_resepnt_into_account: True,
    is_only_single_account: True,
    is_withdrawal_script_present: True,
  }
}

fn mock_test_case_4_2(number_of_inputs: Int, test_case: TestCase42) {
  let TestCase42 {
    is_operation_key_signed,
    is_value_resepnt_into_account,
    is_only_single_account,
    is_withdrawal_script_present,
  } = test_case

  let add_trade_account_input =
    fn(tx_tester: MocktailTx, index: Int) {
      tx_tester
        |> tx_in(
            index < number_of_inputs,
            mock_tx_hash(0),
            index + 1,
            from_lovelace(5_000_000),
            mock_account_address(),
          )
        |> tx_in_inline_datum(index < number_of_inputs, AccountDatum)
    }

  mocktail_tx()
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
    |> tx_in_inline_datum(!is_only_single_account, AccountDatum)
    |> tx_out(
        True,
        mock_account_address(),
        from_lovelace(5_000_000 * ( number_of_inputs - 1 )),
      )
    |> tx_out_inline_datum(True, AccountDatum)
    |> tx_out(
        is_value_resepnt_into_account,
        mock_account_address(),
        from_lovelace(5_000_000 * ( number_of_inputs - 1 )),
      )
    |> tx_out_inline_datum(is_value_resepnt_into_account, AccountDatum)
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> script_withdrawal(is_withdrawal_script_present, script_hash_4_2(), 0)
    |> complete()
    |> add_reference_input(True, mock_account_oracle_ref_input())
}

test t4_2_success() {
  let tx = mock_test_case_4_2(10, base_test_case_4_2())
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_2()))),
      transaction: tx,
    }
  account_process(0, tx, AccountAppUnlock) && account_app_unlock(
    mock_account_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}

test t4_2_failed_without_operation_key_signed() {
  let tx =
    mock_test_case_4_2(
      10,
      TestCase42 { ..base_test_case_4_2(), is_operation_key_signed: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_2()))),
      transaction: tx,
    }
  account_process(0, tx, AccountAppUnlock) && !account_app_unlock(
    mock_account_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}

test t4_2_failed_without_value_resepnt_into_account() {
  let tx =
    mock_test_case_4_2(
      10,
      TestCase42 {
        ..base_test_case_4_2(),
        is_value_resepnt_into_account: False,
      },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_2()))),
      transaction: tx,
    }
  account_process(0, tx, AccountAppUnlock) && !account_app_unlock(
    mock_account_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}

test t4_2_failed_with_other_account_unlock_attempt() {
  let tx =
    mock_test_case_4_2(
      10,
      TestCase42 { ..base_test_case_4_2(), is_only_single_account: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_2()))),
      transaction: tx,
    }
  account_process(0, tx, AccountAppUnlock) && !account_app_unlock(
    mock_account_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}

test t4_2_failed_without_withdrawal_script_present() {
  let tx =
    mock_test_case_4_2(
      10,
      TestCase42 { ..base_test_case_4_2(), is_withdrawal_script_present: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_2()))),
      transaction: tx,
    }
  !account_process(0, tx, AccountAppUnlock) && account_app_unlock(
    mock_account_oracle_policy_id(),
    Void,
    withdrawal_ctx,
  )
}
