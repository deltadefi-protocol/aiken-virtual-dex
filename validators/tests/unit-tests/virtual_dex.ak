use aiken/transaction.{ScriptContext, Spend, Transaction, placeholder}
use aiken/transaction/value.{from_asset}
use aiken_virtual_dex/placeholder.{
  ada_asset_class, mock_buy_ada_order_input, mock_change_account_address,
  mock_emergency_token, mock_fee_address, mock_fee_output, mock_fee_ref_input,
  mock_operation_key, mock_oracle_policy_id, mock_oracle_ref_input,
  mock_post_trade_trade_account_output, mock_token_asset_class,
  mock_trade_account_address, mock_utxo_ref,
}
use aiken_virtual_dex/types.{TakeOrder, VirtualDexDatum}
use aiken_virtual_dex/validators/virtual_dex.{virtual_dex_logic}

type TakeOrderTestCase {
  is_fee_ref_correct: Bool,
  is_token_paid_to_maker: Bool,
  is_min_fee_paid: Bool,
  is_percentage_fee_paid: Bool,
  is_operation_key_signed: Bool,
}

fn take_order_base_case() {
  TakeOrderTestCase {
    is_fee_ref_correct: True,
    is_token_paid_to_maker: True,
    is_min_fee_paid: True,
    is_percentage_fee_paid: True,
    is_operation_key_signed: True,
  }
}

fn take_order_test(test_case: TakeOrderTestCase) {
  let TakeOrderTestCase {
    is_fee_ref_correct,
    is_token_paid_to_maker: _,
    is_min_fee_paid,
    is_percentage_fee_paid,
    is_operation_key_signed,
  } = test_case
  let min_fee = 2_000_000
  let percentage_fee_times_10k = 500
  let reference_inputs =
    if is_fee_ref_correct {
      [
        mock_oracle_ref_input(),
        mock_fee_ref_input(min_fee, percentage_fee_times_10k),
      ]
    } else {
      [mock_oracle_ref_input()]
    }
  let extra_signatories =
    if is_operation_key_signed {
      [mock_operation_key()]
    } else {
      []
    }

  let token_lot_size = 310_000_000
  let ada_lot_size = 500_000_000
  let inputs =
    [
      mock_buy_ada_order_input(1, ada_lot_size / token_lot_size, token_lot_size),
      mock_buy_ada_order_input(2, ada_lot_size / token_lot_size, token_lot_size),
      mock_buy_ada_order_input(3, ada_lot_size / token_lot_size, token_lot_size),
    ]
  let fee_output =
    when (is_min_fee_paid, is_percentage_fee_paid) is {
      (True, True) -> mock_fee_output(token_lot_size, min_fee, 0)
      (True, False) -> mock_fee_output(token_lot_size, 0, 0)
      (False, True) -> mock_fee_output(token_lot_size, 0, 0)
      (False, False) -> mock_fee_output(token_lot_size, 0, 0)
    }
  let to_user_output =
    mock_post_trade_trade_account_output(from_asset("", "", token_lot_size * 3))
  let outputs =
    [fee_output, to_user_output]
  Transaction {
    ..placeholder(),
    reference_inputs: reference_inputs,
    extra_signatories: extra_signatories,
    inputs: inputs,
    outputs: outputs,
  }
}

test success_take_order() {
  let input_utxo = mock_utxo_ref(51)
  let dat =
    VirtualDexDatum {
      change_account_address: mock_change_account_address(),
      trade_account_address: mock_trade_account_address(),
      is_long: True,
      list_price_times_10k: 60000,
      sell_lot_size: 500,
    }
  let red = TakeOrder
  let tx = take_order_test(take_order_base_case())
  let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
  virtual_dex_logic(
    mock_oracle_policy_id(),
    mock_emergency_token(),
    mock_fee_address(),
    ada_asset_class(),
    mock_token_asset_class(),
    dat,
    red,
    ctx,
  )
}

type MassTakeOrderTestCase {
  is_output_from_own_address: Bool,
  is_redeemer_correct: Bool,
}

fn mass_take_order_base_case() {
  MassTakeOrderTestCase {
    is_output_from_own_address: True,
    is_redeemer_correct: True,
  }
}

type CancelOrderTestCase {
  is_order_value_returned: Bool,
  is_operation_key_signed: Bool,
}

fn cancel_order_base_case() {
  CancelOrderTestCase {
    is_order_value_returned: True,
    is_operation_key_signed: True,
  }
}
// type EmergencyCancelTestCase {
//   is_emergency_token_burnt: Bool,
// }
