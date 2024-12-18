use aiken/collection/list
use aiken_virtual_dex/placeholder.{
  mock_dex_oracle_datum, mock_dex_oracle_output, mock_dex_oracle_policy_id,
  mock_operation_key, mock_stop_key,
} as dex_placeholder
use aiken_virtual_dex/types.{DexOracleDatum, DexRotateKey, StopDex}
use cardano/assets.{from_asset}
use cardano/transaction.{Input, Transaction, placeholder}
use dex_oracle
use mocktail/virgin_key_hash.{mock_pub_key_hash}
use mocktail/virgin_output_reference.{mock_utxo_ref}

type RotateTestCase {
  is_old_stop_key_signed: Bool,
  is_new_stop_key_signed: Bool,
  is_datum_updated: Bool,
}

fn base_rotate_test_case() {
  RotateTestCase {
    is_old_stop_key_signed: True,
    is_new_stop_key_signed: True,
    is_datum_updated: True,
  }
}

fn mock_rotate_test_case(test_case: RotateTestCase) {
  let RotateTestCase {
    is_old_stop_key_signed,
    is_new_stop_key_signed,
    is_datum_updated,
  } = test_case
  let input_utxo = mock_utxo_ref(0, 0)
  let new_stop_key = mock_pub_key_hash(3)

  let extra_signatories =
    []
      |> list.concat(
          if is_old_stop_key_signed {
            [mock_stop_key()]
          } else {
            []
          },
        )
      |> list.concat(
          if is_new_stop_key_signed {
            [new_stop_key]
          } else {
            []
          },
        )
  let new_datum =
    if is_datum_updated {
      DexOracleDatum {
        ..mock_dex_oracle_datum(),
        operation_key: mock_stop_key(),
        stop_key: new_stop_key,
      }
    } else {
      mock_dex_oracle_datum()
    }

  let input =
    Input {
      output_reference: input_utxo,
      output: mock_dex_oracle_output(mock_dex_oracle_datum()),
    }
  let output = mock_dex_oracle_output(new_datum)
  Transaction {
    ..placeholder,
    inputs: [input],
    outputs: [output],
    extra_signatories: extra_signatories,
  }
}

test t6_1_success_rotate_key() {
  let redeemer =
    DexRotateKey {
      new_operation_key: mock_stop_key(),
      new_stop_key: mock_pub_key_hash(3),
    }
  let input_utxo = mock_utxo_ref(0, 0)

  let tx = mock_rotate_test_case(base_rotate_test_case())

  dex_oracle.dex_oracle.spend(
    Some(mock_dex_oracle_datum()),
    redeemer,
    input_utxo,
    tx,
  )
}

test t6_1_fail_rotate_key_without_old_stop_signature() {
  let redeemer =
    DexRotateKey {
      new_operation_key: mock_stop_key(),
      new_stop_key: mock_pub_key_hash(3),
    }
  let input_utxo = mock_utxo_ref(0, 0)

  let tx =
    mock_rotate_test_case(
      RotateTestCase {
        ..base_rotate_test_case(),
        is_old_stop_key_signed: False,
      },
    )
  !dex_oracle.dex_oracle.spend(
    Some(mock_dex_oracle_datum()),
    redeemer,
    input_utxo,
    tx,
  )
}

test t6_1_fail_rotate_key_without_new_stop_signature() {
  let redeemer =
    DexRotateKey {
      new_operation_key: mock_stop_key(),
      new_stop_key: mock_pub_key_hash(3),
    }
  let input_utxo = mock_utxo_ref(0, 0)

  let tx =
    mock_rotate_test_case(
      RotateTestCase {
        ..base_rotate_test_case(),
        is_new_stop_key_signed: False,
      },
    )
  !dex_oracle.dex_oracle.spend(
    Some(mock_dex_oracle_datum()),
    redeemer,
    input_utxo,
    tx,
  )
}

// test fail_

test t5_2_success_stop_app() {
  let redeemer = StopDex
  let tx =
    Transaction {
      ..placeholder,
      mint: from_asset(mock_dex_oracle_policy_id(), "", -1),
      extra_signatories: [mock_pub_key_hash(2)],
    }
  dex_oracle.dex_oracle.spend(
    Some(mock_dex_oracle_datum()),
    redeemer,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t5_2_fail_stop_app_without_stop_key() {
  let redeemer = StopDex
  let tx =
    Transaction {
      ..placeholder,
      mint: from_asset(mock_dex_oracle_policy_id(), "", -1),
      extra_signatories: [mock_operation_key()],
    }

  !dex_oracle.dex_oracle.spend(
    Some(mock_dex_oracle_datum()),
    redeemer,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t5_2_success_stop_app_without_oracle_nft_burnt() {
  let redeemer = StopDex
  let tx =
    Transaction {
      ..placeholder,
      mint: from_asset(mock_dex_oracle_policy_id(), "not oracle nft", -1),
      extra_signatories: [mock_stop_key()],
    }

  !dex_oracle.dex_oracle.spend(
    Some(mock_dex_oracle_datum()),
    redeemer,
    mock_utxo_ref(0, 0),
    tx,
  )
}
