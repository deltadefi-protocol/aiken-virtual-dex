use account/emergency_unlock_phase2.{account_emergency_unlock_phase_2}
use aiken/transaction.{ScriptContext, WithdrawFrom}
use aiken/transaction/credential.{Inline, ScriptCredential}
use aiken_virtual_dex/placeholder.{
  mock_account_address, mock_account_input, mock_emergency_token,
  mock_emergency_unlock_phase2_input, mock_operation_key, mock_user_vkey_hex,
  script_hash_4_4,
}
use aiken_virtual_dex/types.{
  AccountEmergencyActionPhase2Redeemer, AccountEmergencyUnlockPhase2,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use mocktail.{
  add_input, add_redeemer, complete, invalid_before, mint, mocktail_tx,
  required_signer_hash, script_withdrawal,
}
use tests/unit_tests/account/account.{account_process}

type TestCase44 {
  is_owner_signed: Bool,
  is_input_datum_correct: Bool,
  is_time_valid: Bool,
  is_emergency_token_burnt: Bool,
  is_withdrawal_script_present: Bool,
}

fn base_emergency_action_test_case() {
  TestCase44 {
    is_owner_signed: True,
    is_input_datum_correct: True,
    is_time_valid: True,
    is_emergency_token_burnt: True,
    is_withdrawal_script_present: True,
  }
}

fn mock_redeemer() {
  AccountEmergencyActionPhase2Redeemer { owner: mock_user_vkey_hex() }
}

fn mock_emergency_action_test_case(test_case: TestCase44) {
  let TestCase44 {
    is_owner_signed,
    is_input_datum_correct,
    is_time_valid,
    is_emergency_token_burnt,
    is_withdrawal_script_present,
  } = test_case

  let redeemer: Data = mock_redeemer()

  mocktail_tx()
    |> required_signer_hash(is_owner_signed, mock_user_vkey_hex())
    |> mint(
        is_emergency_token_burnt,
        -1,
        mock_emergency_token(),
        get_emergency_token_name(mock_account_address()),
      )
    |> invalid_before(is_time_valid, 101)
    |> invalid_before(!is_time_valid, 99)
    |> script_withdrawal(is_withdrawal_script_present, script_hash_4_4(), 0)
    |> complete()
    |> add_input(True, mock_account_input(1))
    |> add_input(True, mock_account_input(2))
    |> add_input(
        is_input_datum_correct,
        mock_emergency_unlock_phase2_input(1, 100, mock_user_vkey_hex()),
      )
    |> add_input(
        !is_input_datum_correct,
        mock_emergency_unlock_phase2_input(1, 100, mock_operation_key()),
      )
    |> add_redeemer(
        True,
        Pair(WithdrawFrom(Inline(ScriptCredential(script_hash_4_4()))),
        redeemer),
      )
}

test t4_4_success() {
  let tx = mock_emergency_action_test_case(base_emergency_action_test_case())
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_4()))),
      transaction: tx,
    }
  account_process(31, tx, AccountEmergencyUnlockPhase2) && account_emergency_unlock_phase_2(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_4_failed_emergency_withdraw_without_owner_signature() {
  let tx =
    mock_emergency_action_test_case(
      TestCase44 { ..base_emergency_action_test_case(), is_owner_signed: False },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_4()))),
      transaction: tx,
    }
  account_process(31, tx, AccountEmergencyUnlockPhase2) && !account_emergency_unlock_phase_2(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_4_failed_emergency_withdraw_with_invalid_time() {
  let tx =
    mock_emergency_action_test_case(
      TestCase44 { ..base_emergency_action_test_case(), is_time_valid: False },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_4()))),
      transaction: tx,
    }
  account_process(31, tx, AccountEmergencyUnlockPhase2) && !account_emergency_unlock_phase_2(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_4_failed_emergency_withdraw_without_emergency_token_burnt() {
  let tx =
    mock_emergency_action_test_case(
      TestCase44 {
        ..base_emergency_action_test_case(),
        is_emergency_token_burnt: False,
      },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_4()))),
      transaction: tx,
    }
  account_process(31, tx, AccountEmergencyUnlockPhase2) && !account_emergency_unlock_phase_2(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_4_failed_initiate_emergency_without_withdrawal() {
  let tx =
    mock_emergency_action_test_case(
      TestCase44 {
        ..base_emergency_action_test_case(),
        is_withdrawal_script_present: False,
      },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_4()))),
      transaction: tx,
    }
  !account_process(31, tx, AccountEmergencyUnlockPhase2) && account_emergency_unlock_phase_2(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}
