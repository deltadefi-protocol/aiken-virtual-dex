use account/emergency_unlock_phase1.{account_emergency_unlock_phase_1}
use aiken/transaction.{Input, ScriptContext, WithdrawFrom}
use aiken/transaction/credential.{Inline, ScriptCredential}
use aiken_virtual_dex/placeholder.{
  mock_account_address, mock_emergency_token, mock_emergency_unlock_phase1_input,
  mock_emergency_unlock_phase1_output, mock_emergency_unlock_phase1_utxo,
  mock_emergency_unlock_phase2_output, mock_operation_key, mock_user_vkey_hex,
  script_hash_4_3,
}
use aiken_virtual_dex/types.{
  AccountEmergencyActionPhase1Redeemer, AccountEmergencyUnlockPhase1,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use sidan_placeholder/builder.{
  complete, invalid_hereafter, mint, new_tx_tester, required_signer_hash,
  script_withdrawal,
}
use sidan_placeholder/output_reference.{mock_utxo_ref}
use sidan_placeholder/transaction.{add_input,
  add_output, add_redeemer} as sidan_tx
use tests/unit_tests/account/account.{account_process}

type TestCase43 {
  is_owner_signed: Bool,
  is_emergency_token_minted: Bool,
  is_input_datum_correct: Bool,
  is_output_correct: Bool,
  is_time_valid: Bool,
  is_withdrawal_script_present: Bool,
}

fn base_test_case() {
  TestCase43 {
    is_owner_signed: True,
    is_emergency_token_minted: True,
    is_input_datum_correct: True,
    is_output_correct: True,
    is_time_valid: True,
    is_withdrawal_script_present: True,
  }
}

fn mock_redeemer() {
  AccountEmergencyActionPhase1Redeemer {
    owner: mock_user_vkey_hex(),
    own_input: mock_emergency_unlock_phase1_utxo(1),
    initiate_before: 100,
  }
}

fn mock_initiate_emergency_test_case(test_case: TestCase43) {
  let TestCase43 {
    is_owner_signed,
    is_emergency_token_minted,
    is_input_datum_correct,
    is_output_correct,
    is_time_valid,
    is_withdrawal_script_present,
  } = test_case

  let redeemer: Data = mock_redeemer()

  new_tx_tester()
    |> required_signer_hash(is_owner_signed, mock_user_vkey_hex())
    |> mint(
        is_emergency_token_minted,
        1,
        mock_emergency_token(),
        get_emergency_token_name(mock_account_address()),
      )
    |> invalid_hereafter(is_time_valid, 99)
    |> invalid_hereafter(!is_time_valid, 101)
    |> script_withdrawal(is_withdrawal_script_present, script_hash_4_3(), 0)
    |> complete()
    |> add_input(is_input_datum_correct, mock_emergency_unlock_phase1_input(1))
    |> add_input(
        !is_input_datum_correct,
        Input {
          output_reference: mock_utxo_ref(0, 21),
          output: mock_emergency_unlock_phase1_output(mock_operation_key()),
        },
      )
    |> add_output(
        is_output_correct,
        mock_emergency_unlock_phase2_output(100, mock_user_vkey_hex()),
      )
    |> add_output(
        !is_output_correct,
        mock_emergency_unlock_phase2_output(101, mock_user_vkey_hex()),
      )
    |> add_redeemer(
        True,
        Pair(WithdrawFrom(Inline(ScriptCredential(script_hash_4_3()))),
        redeemer),
      )
}

test t4_3_success() {
  let tx = mock_initiate_emergency_test_case(base_test_case())
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_3()))),
      transaction: tx,
    }
  account_process(21, tx, AccountEmergencyUnlockPhase1) && account_emergency_unlock_phase_1(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_3_failed_initiate_emergency_without_owner_signature() {
  let tx =
    mock_initiate_emergency_test_case(
      TestCase43 { ..base_test_case(), is_owner_signed: False },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_3()))),
      transaction: tx,
    }
  account_process(21, tx, AccountEmergencyUnlockPhase1) && !account_emergency_unlock_phase_1(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_3_failed_initiate_emergency_without_emergency_token_minted() {
  let tx =
    mock_initiate_emergency_test_case(
      TestCase43 { ..base_test_case(), is_emergency_token_minted: False },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_3()))),
      transaction: tx,
    }
  account_process(21, tx, AccountEmergencyUnlockPhase1) && !account_emergency_unlock_phase_1(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_3_failed_initiate_emergency_without_correct_input_datum() {
  let tx =
    mock_initiate_emergency_test_case(
      TestCase43 { ..base_test_case(), is_input_datum_correct: False },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_3()))),
      transaction: tx,
    }
  account_process(21, tx, AccountEmergencyUnlockPhase1) && !account_emergency_unlock_phase_1(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_3_failed_initiate_emergency_without_correct_output() {
  let tx =
    mock_initiate_emergency_test_case(
      TestCase43 { ..base_test_case(), is_output_correct: False },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_3()))),
      transaction: tx,
    }
  account_process(21, tx, AccountEmergencyUnlockPhase1) && !account_emergency_unlock_phase_1(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_3_failed_initiate_emergency_with_invalid_time() {
  let tx =
    mock_initiate_emergency_test_case(
      TestCase43 { ..base_test_case(), is_time_valid: False },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_3()))),
      transaction: tx,
    }
  account_process(21, tx, AccountEmergencyUnlockPhase1) && !account_emergency_unlock_phase_1(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}

test t4_3_failed_initiate_emergency_without_withdrawal() {
  let tx =
    mock_initiate_emergency_test_case(
      TestCase43 { ..base_test_case(), is_withdrawal_script_present: False },
    )
  let ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_4_3()))),
      transaction: tx,
    }
  !account_process(21, tx, AccountEmergencyUnlockPhase1) && account_emergency_unlock_phase_1(
    mock_emergency_token(),
    mock_redeemer(),
    ctx,
  )
}
