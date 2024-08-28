use aiken/transaction.{Mint, ScriptContext, Transaction, placeholder}
use aiken/transaction/value.{add, from_asset, to_minted_value}
use aiken_virtual_dex/placeholder.{
  mock_emergency_action_input, mock_emergency_action_output,
  mock_emergency_token, mock_emergency_unlock_address, mock_user_vkey_hex,
}
use aiken_virtual_dex/types.{EBurn, EMint}
use emergency_token.{emergency_token}
use mocktail/virgin_validity_range.{mock_interval}

type TestCase {
  is_owner_signed: Bool,
  is_emergency_token_name_correct: Bool,
  is_datum_correct: Bool,
  is_time_valid: Bool,
}

fn base_test_case() -> TestCase {
  TestCase {
    is_owner_signed: True,
    is_emergency_token_name_correct: True,
    is_datum_correct: True,
    is_time_valid: True,
  }
}

fn mint_test_case(test_case: TestCase) {
  let TestCase {
    is_owner_signed,
    is_emergency_token_name_correct,
    is_datum_correct,
    is_time_valid,
  } = test_case
  let extra_signatories =
    if is_owner_signed {
      [mock_user_vkey_hex()]
    } else {
      []
    }
  let mint =
    if is_emergency_token_name_correct {
      to_minted_value(from_asset(mock_emergency_token(), #"", 1))
    } else {
      to_minted_value(from_asset(mock_emergency_token(), "Incorrect name", 1))
    }
  let validity_range =
    mock_interval(
      Some(
        if is_time_valid {
          101
        } else {
          99
        },
      ),
      None,
    )
  let outputs =
    [
      mock_emergency_action_output(
        if is_datum_correct {
          100
        } else {
          200
        },
        mock_emergency_unlock_address(),
        mock_user_vkey_hex(),
      ),
    ]
  Transaction {
    ..placeholder(),
    extra_signatories: extra_signatories,
    mint: mint,
    validity_range: validity_range,
    inputs: [],
    outputs: outputs,
  }
}

test t2_1_success_mint() {
  let redeemer = EMint { current_timestamp: 100 }
  let policy_id = mock_emergency_token()

  let tx = mint_test_case(base_test_case())
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  emergency_token(mock_emergency_unlock_address(), redeemer, ctx)
}

test t2_1_fail_mint_without_owner_signature() {
  let redeemer = EMint { current_timestamp: 100 }
  let policy_id = mock_emergency_token()

  let tx =
    mint_test_case(TestCase { ..base_test_case(), is_owner_signed: False })
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !emergency_token(mock_emergency_unlock_address(), redeemer, ctx)
}

test t2_1_fail_mint_with_incorrect_emergency_token_name() {
  let redeemer = EMint { current_timestamp: 100 }
  let policy_id = mock_emergency_token()

  let tx =
    mint_test_case(
      TestCase { ..base_test_case(), is_emergency_token_name_correct: False },
    )
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !emergency_token(mock_emergency_unlock_address(), redeemer, ctx)
}

test t2_1_fail_mint_without_correct_datum() {
  let redeemer = EMint { current_timestamp: 100 }
  let policy_id = mock_emergency_token()

  let tx =
    mint_test_case(TestCase { ..base_test_case(), is_datum_correct: False })
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !emergency_token(mock_emergency_unlock_address(), redeemer, ctx)
}

test t2_1_fail_mint_with_invalid_time() {
  let redeemer = EMint { current_timestamp: 100 }
  let policy_id = mock_emergency_token()

  let tx = mint_test_case(TestCase { ..base_test_case(), is_time_valid: False })
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !emergency_token(mock_emergency_unlock_address(), redeemer, ctx)
}

test t2_2_success_burn() {
  let redeemer = EBurn
  let policy_id = mock_emergency_token()

  let tx =
    Transaction {
      ..placeholder(),
      inputs: [mock_emergency_action_input(10, 100, mock_user_vkey_hex())],
      extra_signatories: [mock_user_vkey_hex()],
      validity_range: mock_interval(Some(100 + 86401), None),
      mint: to_minted_value(from_asset(policy_id, #"", -1)),
    }
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  emergency_token(mock_emergency_unlock_address(), redeemer, ctx)
}

test t2_2_fail_burn_with_mint() {
  let redeemer = EBurn
  let policy_id = mock_emergency_token()

  let tx =
    Transaction {
      ..placeholder(),
      inputs: [mock_emergency_action_input(10, 100, mock_user_vkey_hex())],
      extra_signatories: [mock_user_vkey_hex()],
      validity_range: mock_interval(Some(100 + 86401), None),
      mint: to_minted_value(from_asset(policy_id, "", 1)),
    }
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !emergency_token(mock_emergency_unlock_address(), redeemer, ctx)
}

test t2_2_fail_burn_with_mix() {
  let redeemer = EBurn
  let policy_id = mock_emergency_token()

  let tx =
    Transaction {
      ..placeholder(),
      inputs: [mock_emergency_action_input(10, 100, mock_user_vkey_hex())],
      extra_signatories: [mock_user_vkey_hex()],
      validity_range: mock_interval(Some(100 + 86401), None),
      mint: to_minted_value(
        from_asset(policy_id, "", -1) |> add(policy_id, "1", 1),
      ),
    }
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !emergency_token(mock_emergency_unlock_address(), redeemer, ctx)
}
