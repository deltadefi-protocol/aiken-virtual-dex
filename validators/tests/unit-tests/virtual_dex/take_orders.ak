use aiken_virtual_dex/placeholder.{
  ada_asset_class, mock_account_address, mock_buy_ada_order_input,
  mock_dex_oracle_policy_id, mock_dex_oracle_ref_input, mock_emergency_token,
  mock_fee_output, mock_operation_key, mock_post_trade_account_output,
  mock_token_asset_class, script_hash_5_1,
}
use aiken_virtual_dex/types.{TakeOrders, VirtualDexDatum, VirtualDexRedeemer}
use cardano/address.{Script}
use cardano/assets.{from_asset}
use cardano/transaction.{Transaction}
use mocktail.{
  add_input, add_output, add_reference_input, complete, mocktail_tx,
  required_signer_hash, script_withdrawal,
}
use mocktail/virgin_output_reference.{mock_utxo_ref}
use virtual_dex/take_orders
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

type TestCase51 {
  is_token_paid_to_maker: Bool,
  is_extra_lovelace_returned: Bool,
  is_operation_key_signed: Bool,
  is_withdrawal_script_present: Bool,
}

fn take_order_base_case() {
  TestCase51 {
    is_token_paid_to_maker: True,
    is_extra_lovelace_returned: True,
    is_operation_key_signed: True,
    is_withdrawal_script_present: True,
  }
}

fn take_order_test(test_case: TestCase51) {
  let TestCase51 {
    is_token_paid_to_maker,
    is_extra_lovelace_returned,
    is_operation_key_signed,
    is_withdrawal_script_present,
  } = test_case
  let token_lot_size = 310_000_000
  let ada_lot_size = 500_000_000
  let min_fee = 2_000_000
  let list_price_times_1mil = ada_lot_size * 1000000 / token_lot_size
  let percentage_fee_times_10k = 5

  mocktail_tx()
    |> script_withdrawal(is_withdrawal_script_present, script_hash_5_1(), 0)
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> complete()
    |> add_reference_input(True, mock_dex_oracle_ref_input())
    |> add_output(
        True,
        mock_fee_output(ada_lot_size * 3, min_fee, percentage_fee_times_10k),
      )
    |> add_output(
        True,
        mock_post_trade_account_output(
          from_asset(
            "",
            "",
            if is_token_paid_to_maker {
              ada_lot_size * 3
            } else {
              ada_lot_size * 3 - 1
            },
          ),
        ),
      )
    |> add_output(
        True,
        mock_post_trade_account_output(
          from_asset(
            "",
            "",
            if is_extra_lovelace_returned {
              5_000_000 * 3
            } else {
              4_999_999 * 3
            },
          ),
        ),
      )
    |> add_input(
        True,
        mock_buy_ada_order_input(
          1,
          list_price_times_1mil,
          ada_lot_size,
          5_000_000,
          0,
        ),
      )
    |> add_input(
        True,
        mock_buy_ada_order_input(
          2,
          list_price_times_1mil,
          ada_lot_size,
          5_000_000,
          0,
        ),
      )
    |> add_input(
        True,
        mock_buy_ada_order_input(
          3,
          list_price_times_1mil,
          ada_lot_size,
          5_000_000,
          0,
        ),
      )
}

test t6_1_success_take_order() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
      extra_lovelace: 0,
    }
  let tx = take_order_test(take_order_base_case())
  virtual_dex_process(1, tx, dat, TakeOrders) && take_orders.virtual_dex_take_orders.withdraw(
    mock_dex_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    Script(script_hash_5_1()),
    tx,
  )
}

test t6_1_fail_take_order_without_extra_lovelace_returned() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
      extra_lovelace: 0,
    }
  let tx =
    take_order_test(
      TestCase51 { ..take_order_base_case(), is_extra_lovelace_returned: False },
    )
  virtual_dex_process(1, tx, dat, TakeOrders) && !take_orders.virtual_dex_take_orders.withdraw(
    mock_dex_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    Script(script_hash_5_1()),
    tx,
  )
}

test t6_1_fail_take_order_without_token_paid_to_maker() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
      extra_lovelace: 0,
    }
  let tx =
    take_order_test(
      TestCase51 { ..take_order_base_case(), is_token_paid_to_maker: False },
    )
  virtual_dex_process(1, tx, dat, TakeOrders) && !take_orders.virtual_dex_take_orders.withdraw(
    mock_dex_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    Script(script_hash_5_1()),
    tx,
  )
}

test t6_1_fail_take_order_without_operation_key_signed() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
      extra_lovelace: 0,
    }
  let tx =
    take_order_test(
      TestCase51 { ..take_order_base_case(), is_operation_key_signed: False },
    )
  virtual_dex_process(1, tx, dat, TakeOrders) && !take_orders.virtual_dex_take_orders.withdraw(
    mock_dex_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    Script(script_hash_5_1()),
    tx,
  )
}

test t6_1_failed_without_withdrawal_script_present() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
      extra_lovelace: 0,
    }
  let tx =
    take_order_test(
      TestCase51 {
        ..take_order_base_case(),
        is_withdrawal_script_present: False,
      },
    )
  !virtual_dex_process(1, tx, dat, TakeOrders) && take_orders.virtual_dex_take_orders.withdraw(
    mock_dex_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    Script(script_hash_5_1()),
    tx,
  )
}
