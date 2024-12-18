use aiken_virtual_dex/placeholder.{
  mock_account_address, mock_buy_ada_order_input, mock_dex_oracle_policy_id,
  mock_dex_oracle_ref_input, mock_emergency_token, mock_operation_key,
  mock_post_trade_account_output, mock_user_vkey_hex, script_hash_5_1,
} as dex_placeholder
use aiken_virtual_dex/types.{
  CancelOrder, EmergencyCancel, VirtualDexDatum, VirtualDexRedeemer,
}
use cardano/assets.{add}
use cardano/transaction.{Input, Output, Transaction, placeholder}
use mocktail.{complete, mint, mocktail_tx, required_signer_hash}
use mocktail/virgin_output_reference.{mock_utxo_ref}
use virtual_dex/virtual_dex

fn virtual_dex_process(
  index: Int,
  tx: Transaction,
  datum: VirtualDexDatum,
  redeemer: VirtualDexRedeemer,
) {
  let input = mock_utxo_ref(0, 50 + index)
  virtual_dex.virtual_dex.spend(
    mock_dex_oracle_policy_id(),
    mock_emergency_token(),
    script_hash_5_1(),
    Some(datum),
    redeemer,
    input,
    tx,
  )
}

type TestCase72 {
  is_order_value_returned: Bool,
  is_operation_key_signed: Bool,
}

fn cancel_order_base_case() {
  TestCase72 { is_order_value_returned: True, is_operation_key_signed: True }
}

fn cancel_order_test(test_case: TestCase72) {
  let TestCase72 { is_order_value_returned, is_operation_key_signed } =
    test_case
  let inputs =
    [mock_buy_ada_order_input(1, 1612000, 310_000_000, 0, 0)]
  let outputs =
    [
      mock_post_trade_account_output(
        if is_order_value_returned {
          mock_buy_ada_order_input(1, 1612000, 310_000_000, 0, 0).output.value
        } else {
          mock_buy_ada_order_input(1, 1612000, 310_000_000, 0, 0).output.value
            |> add("", "", -1)
        },
      ),
    ]
  let extra_signatories =
    if is_operation_key_signed {
      [mock_operation_key()]
    } else {
      []
    }
  let reference_inputs =
    [mock_dex_oracle_ref_input()]
  Transaction {
    ..placeholder,
    inputs: inputs,
    outputs: outputs,
    reference_inputs: reference_inputs,
    extra_signatories: extra_signatories,
  }
}

test t7_2_success_cancel_order() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 310_000_000,
      extra_lovelace: 0,
      owner: mock_user_vkey_hex(),
    }
  let red = CancelOrder
  let tx = cancel_order_test(cancel_order_base_case())
  virtual_dex_process(1, tx, dat, red)
}

test t7_2_fail_cancel_order_without_value_returned() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 310_000_000,
      extra_lovelace: 0,
      owner: mock_user_vkey_hex(),
    }
  let red = CancelOrder
  let tx =
    cancel_order_test(
      TestCase72 { ..cancel_order_base_case(), is_order_value_returned: False },
    )
  !virtual_dex_process(1, tx, dat, red)
}

test t7_2_fail_cancel_order_without_operation_key_signed() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 310_000_000,
      extra_lovelace: 0,
      owner: mock_user_vkey_hex(),
    }
  let red = CancelOrder
  let tx =
    cancel_order_test(
      TestCase72 { ..cancel_order_base_case(), is_operation_key_signed: False },
    )
  !virtual_dex_process(1, tx, dat, red)
}

test t7_3_success_emergency_cancel() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 310_000_000,
      extra_lovelace: 0,
      owner: mock_user_vkey_hex(),
    }

  let red = EmergencyCancel
  let tx =
    mocktail_tx()
      |> mint(True, -1, mock_emergency_token(), mock_user_vkey_hex())
      |> required_signer_hash(True, mock_user_vkey_hex())
      |> complete()
  virtual_dex_process(1, tx, dat, red)
}

test t7_3_fail_emergency_cancel_without_emergency_token_burnt() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 310_000_000,
      extra_lovelace: 0,
      owner: mock_user_vkey_hex(),
    }

  let red = EmergencyCancel
  let tx =
    mocktail_tx()
      |> required_signer_hash(True, mock_user_vkey_hex())
      |> complete()
  !virtual_dex_process(1, tx, dat, red)
}

test t7_3_fail_emergency_cancel_without_owner_signature() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 310_000_000,
      extra_lovelace: 0,
      owner: mock_user_vkey_hex(),
    }

  let red = EmergencyCancel
  let tx =
    mocktail_tx()
      |> mint(True, -1, mock_emergency_token(), mock_user_vkey_hex())
      |> complete()
  !virtual_dex_process(1, tx, dat, red)
}
