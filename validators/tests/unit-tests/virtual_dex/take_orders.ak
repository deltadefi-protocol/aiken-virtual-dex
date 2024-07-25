use aiken/transaction.{InlineDatum, Input, Output, ScriptContext, WithdrawFrom}
use aiken/transaction/credential.{Inline, ScriptCredential}
use aiken/transaction/value.{from_asset}
use aiken_virtual_dex/placeholder.{
  ada_asset_class, mock_account_address, mock_buy_ada_order_input,
  mock_fee_output, mock_operation_key, mock_oracle_address,
  mock_oracle_policy_id, mock_oracle_ref_input, mock_post_trade_account_output,
  mock_token_asset_class, script_hash_5_1,
}
use aiken_virtual_dex/types.{TakeOrders, VirtualDexDatum}
use aiken_virtual_dex/validators/virtual_dex/take_orders.{
  virtual_dex_take_orders_logic,
}
use sidan_placeholder/builder.{
  complete, new_tx_tester, required_signer_hash, script_withdrawal,
}
use sidan_placeholder/output_reference.{mock_utxo_ref}
use sidan_placeholder/transaction.{add_input,
  add_output, add_reference_input} as sidan_transaction
use tests/unit_tests/virtual_dex/virtual_dex.{virtual_dex_process} as tvirtual_dex

type TestCase51 {
  is_token_paid_to_maker: Bool,
  is_operation_key_signed: Bool,
  is_only_one_script_address: Bool,
  is_withdrawal_script_present: Bool,
}

fn take_order_base_case() {
  TestCase51 {
    is_token_paid_to_maker: True,
    is_operation_key_signed: True,
    is_only_one_script_address: True,
    is_withdrawal_script_present: True,
  }
}

fn take_order_test(test_case: TestCase51) {
  let TestCase51 {
    is_token_paid_to_maker,
    is_operation_key_signed,
    is_only_one_script_address,
    is_withdrawal_script_present,
  } = test_case
  let token_lot_size = 310_000_000
  let ada_lot_size = 500_000_000
  let min_fee = 2_000_000
  let list_price_times_1mil = ada_lot_size * 1000000 / token_lot_size
  let percentage_fee_times_10k = 5

  new_tx_tester()
    |> script_withdrawal(is_withdrawal_script_present, script_hash_5_1(), 0)
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> complete()
    |> add_reference_input(True, mock_oracle_ref_input())
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
    |> add_input(
        True,
        mock_buy_ada_order_input(1, list_price_times_1mil, ada_lot_size, 0),
      )
    |> add_input(
        True,
        mock_buy_ada_order_input(2, list_price_times_1mil, ada_lot_size, 0),
      )
    |> add_input(
        True,
        mock_buy_ada_order_input(3, list_price_times_1mil, ada_lot_size, 0),
      )
    |> add_input(
        !is_only_one_script_address,
        Input {
          output_reference: mock_utxo_ref(1, 51),
          output: Output {
            address: mock_oracle_address(),
            value: from_asset(
              mock_token_asset_class().1st,
              mock_token_asset_class().2nd,
              ada_lot_size,
            ),
            datum: InlineDatum(
              VirtualDexDatum {
                account_address: mock_account_address(),
                is_long: True,
                list_price_times_1mil,
                lot_size: ada_lot_size,
                extra_lovelace: 0,
              },
            ),
            reference_script: None,
          },
        },
      )
}

test t5_1_success_take_order() {
  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
      extra_lovelace: 0,
    }
  let tx = take_order_test(take_order_base_case())
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_5_1()))),
      transaction: tx,
    }
  virtual_dex_process(1, tx, dat, TakeOrders) && virtual_dex_take_orders_logic(
    mock_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    withdrawal_ctx,
  )
}

test t5_1_fail_take_order_without_token_paid_to_maker() {
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
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_5_1()))),
      transaction: tx,
    }
  virtual_dex_process(1, tx, dat, TakeOrders) && !virtual_dex_take_orders_logic(
    mock_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    withdrawal_ctx,
  )
}

test t5_1_fail_take_order_without_operation_key_signed() {
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
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_5_1()))),
      transaction: tx,
    }
  virtual_dex_process(1, tx, dat, TakeOrders) && !virtual_dex_take_orders_logic(
    mock_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    withdrawal_ctx,
  )
}

test t5_1_fail_take_order_with_more_than_one_script_address() {
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
      TestCase51 { ..take_order_base_case(), is_only_one_script_address: False },
    )
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_5_1()))),
      transaction: tx,
    }
  virtual_dex_process(1, tx, dat, TakeOrders) && !virtual_dex_take_orders_logic(
    mock_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    withdrawal_ctx,
  )
}

test t5_1_failed_without_withdrawal_script_present() {
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
  let withdrawal_ctx =
    ScriptContext {
      purpose: WithdrawFrom(Inline(ScriptCredential(script_hash_5_1()))),
      transaction: tx,
    }
  !virtual_dex_process(1, tx, dat, TakeOrders) && virtual_dex_take_orders_logic(
    mock_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    withdrawal_ctx,
  )
}

