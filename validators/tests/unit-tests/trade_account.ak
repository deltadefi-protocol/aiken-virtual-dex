use aiken/transaction.{ScriptContext, Spend, Transaction, placeholder}
use aiken_virtual_dex/placeholder.{
  mock_emergency_token, mock_operation_key, mock_oracle_policy_id,
  mock_oracle_ref_input, mock_user_vkey_hex, mock_utxo_ref,
}
use aiken_virtual_dex/types.{TradeNormalAction, TradeNormalDatum}
use aiken_virtual_dex/validators/trade_account.{trade_account_logic}

type TradeTestCase {
  is_owner_signed: Bool,
  is_operation_key_signed: Bool,
}

fn base_trade_test_case() {
  TradeTestCase { is_owner_signed: True, is_operation_key_signed: True }
}

fn mock_trade_test_case(test_case: TradeTestCase) {
  let TradeTestCase { is_owner_signed, is_operation_key_signed } = test_case
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

test success_trade() {
  let redeemer = TradeNormalAction
  let output_reference = mock_utxo_ref(1)

  let tx = mock_trade_test_case(base_trade_test_case())
  let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
  trade_account_logic(
    mock_oracle_policy_id(),
    mock_user_vkey_hex(),
    mock_emergency_token(),
    TradeNormalDatum,
    redeemer,
    ctx,
  )
}

test fail_trade_without_operation_key() {
  let redeemer = TradeNormalAction
  let output_reference = mock_utxo_ref(1)

  let tx =
    mock_trade_test_case(
      TradeTestCase { ..base_trade_test_case(), is_operation_key_signed: False },
    )
  let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
  !trade_account_logic(
    mock_oracle_policy_id(),
    mock_user_vkey_hex(),
    mock_emergency_token(),
    TradeNormalDatum,
    redeemer,
    ctx,
  )
}

test fail_trade_without_owner_key() {
  let redeemer = TradeNormalAction
  let output_reference = mock_utxo_ref(1)

  let tx =
    mock_trade_test_case(
      TradeTestCase { ..base_trade_test_case(), is_owner_signed: False },
    )
  let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
  !trade_account_logic(
    mock_oracle_policy_id(),
    mock_user_vkey_hex(),
    mock_emergency_token(),
    TradeNormalDatum,
    redeemer,
    ctx,
  )
}

type EmergencyActionTestCase {
  is_owner_signed: Bool,
  is_input_datum_correct: Bool,
  is_time_valid: Bool,
  is_emergency_token_burnt: Bool,
}

fn base_emergency_action_test_case() {
  EmergencyActionTestCase {
    is_owner_signed: True,
    is_input_datum_correct: True,
    is_time_valid: True,
    is_emergency_token_burnt: True,
  }
}

type InitiateEmergencyTestCase {
  is_owner_signed: Bool,
  is_emergency_token_minted: Bool,
  is_input_datum_correct: Bool,
  is_output_correct: Bool,
  is_time_valid: Bool,
}

fn base_initiate_emergency_test_case() {
  InitiateEmergencyTestCase {
    is_owner_signed: True,
    is_emergency_token_minted: True,
    is_input_datum_correct: True,
    is_output_correct: True,
    is_time_valid: True,
  }
}
