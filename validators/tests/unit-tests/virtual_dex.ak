use aiken/dict
use aiken/transaction.{
  Input, Output, ScriptContext, Spend, Transaction, placeholder,
}
use aiken/transaction/value.{add, from_asset, to_minted_value}
use aiken_virtual_dex/common.{compare_output_reference}
use aiken_virtual_dex/placeholder.{
  ada_asset_class, mock_buy_ada_order_input, mock_change_account_address,
  mock_emergency_token, mock_fee_output, mock_operation_key, mock_oracle_address,
  mock_oracle_policy_id, mock_oracle_ref_input,
  mock_post_trade_trade_account_output, mock_token_asset_class,
  mock_trade_account_address, mock_utxo_ref,
}
use aiken_virtual_dex/types.{
  CancelOrder, EmergencyCancel, MassTakeOrder, TakeOrder, VirtualDexDatum,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}
use aiken_virtual_dex/validators/virtual_dex.{virtual_dex_logic}

type TakeOrderTestCase {
  is_token_paid_to_maker: Bool,
  is_operation_key_signed: Bool,
}

fn take_order_base_case() {
  TakeOrderTestCase {
    is_token_paid_to_maker: True,
    is_operation_key_signed: True,
  }
}

fn take_order_test(test_case: TakeOrderTestCase) {
  let TakeOrderTestCase { is_token_paid_to_maker, is_operation_key_signed } =
    test_case
  let token_lot_size = 310_000_000
  let ada_lot_size = 500_000_000
  let min_fee = 2_000_000

  let percentage_fee_times_10k = 5
  let fee_output =
    mock_fee_output(ada_lot_size * 3, min_fee, percentage_fee_times_10k)

  let reference_inputs =
    [mock_oracle_ref_input()]
  let extra_signatories =
    if is_operation_key_signed {
      [mock_operation_key()]
    } else {
      []
    }
  let inputs =
    [
      mock_buy_ada_order_input(
        1,
        ada_lot_size * 1000000 / token_lot_size,
        ada_lot_size,
      ),
      mock_buy_ada_order_input(
        2,
        ada_lot_size * 1000000 / token_lot_size,
        ada_lot_size,
      ),
      mock_buy_ada_order_input(
        3,
        ada_lot_size * 1000000 / token_lot_size,
        ada_lot_size,
      ),
    ]
  let to_user_output =
    mock_post_trade_trade_account_output(
      from_asset(
        "",
        "",
        if is_token_paid_to_maker {
          ada_lot_size * 3
        } else {
          ada_lot_size * 3 - 1
        },
      ),
    )
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
      list_price_times_1mil: 60000,
      lot_size: 500,
    }
  let red = TakeOrder
  let tx = take_order_test(take_order_base_case())
  let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
  virtual_dex_logic(
    mock_oracle_policy_id(),
    mock_emergency_token(),
    ada_asset_class(),
    mock_token_asset_class(),
    dat,
    red,
    ctx,
  )
}

test fail_take_order_without_token_paid_to_maker() {
  let input_utxo = mock_utxo_ref(51)
  let dat =
    VirtualDexDatum {
      change_account_address: mock_change_account_address(),
      trade_account_address: mock_trade_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
    }
  let red = TakeOrder
  let tx =
    take_order_test(
      TakeOrderTestCase {
        ..take_order_base_case(),
        is_token_paid_to_maker: False,
      },
    )
  let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
  !virtual_dex_logic(
    mock_oracle_policy_id(),
    mock_emergency_token(),
    ada_asset_class(),
    mock_token_asset_class(),
    dat,
    red,
    ctx,
  )
}

test fail_take_order_without_operation_key_signed() {
  let input_utxo = mock_utxo_ref(51)
  let dat =
    VirtualDexDatum {
      change_account_address: mock_change_account_address(),
      trade_account_address: mock_trade_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
    }
  let red = TakeOrder
  let tx =
    take_order_test(
      TakeOrderTestCase {
        ..take_order_base_case(),
        is_operation_key_signed: False,
      },
    )
  let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
  !virtual_dex_logic(
    mock_oracle_policy_id(),
    mock_emergency_token(),
    ada_asset_class(),
    mock_token_asset_class(),
    dat,
    red,
    ctx,
  )
}

type MassTakeOrderTestCase {
  is_input_from_own_address: Bool,
  is_redeemer_correct: Bool,
}

fn mass_take_order_base_case() {
  MassTakeOrderTestCase {
    is_input_from_own_address: True,
    is_redeemer_correct: True,
  }
}
// fn mass_take_order_test(test_case: MassTakeOrderTestCase) {
//   let MassTakeOrderTestCase { is_input_from_own_address, is_redeemer_correct } =
//     test_case
//   let inputs =
//     [
//       if is_input_from_own_address {
//         mock_buy_ada_order_input(1, 1612000, 310_000_000)
//       } else {
//         Input {
//           output_reference: mock_utxo_ref(51),
//           output: Output {
//             ..mock_buy_ada_order_input(1, 1612000, 310_000_000).output,
//             address: mock_oracle_address(),
//           },
//         }
//       },
//       mock_buy_ada_order_input(2, 1612000, 310_000_000),
//       mock_buy_ada_order_input(3, 1612000, 310_000_000),
//     ]
//   let mass_take_order_red: Data =
//     MassTakeOrder { take_order_input: mock_utxo_ref(51) }
//   let take_order_red: Data = TakeOrder
//   let redeemers =
//     dict.new()
//       |> dict.insert(
//            Spend(mock_utxo_ref(51)),
//            if is_redeemer_correct {
//              take_order_red
//            } else {
//              mass_take_order_red
//            },
//            compare_output_reference,
//          )
//       |> dict.insert(
//            Spend(mock_utxo_ref(52)),
//            mass_take_order_red,
//            compare_output_reference,
//          )
//       |> dict.insert(
//            Spend(mock_utxo_ref(53)),
//            mass_take_order_red,
//            compare_output_reference,
//          )
//   Transaction { ..placeholder(), inputs: inputs, redeemers: redeemers }
// }

// test success_mass_take_order() {
//   let input_utxo = mock_utxo_ref(52)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 500,
//     }
//   let red = MassTakeOrder { take_order_input: mock_utxo_ref(51) }
//   let tx = mass_take_order_test(mass_take_order_base_case())
//   let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
//   virtual_dex_logic(
//     mock_oracle_policy_id(),
//     mock_emergency_token(),
//     ada_asset_class(),
//     mock_token_asset_class(),
//     dat,
//     red,
//     ctx,
//   )
// }

// test fail_mass_take_order_without_correct_redeemer_at_take_order() {
//   let input_utxo = mock_utxo_ref(52)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 500,
//     }
//   let red = MassTakeOrder { take_order_input: mock_utxo_ref(51) }
//   let tx =
//     mass_take_order_test(
//       MassTakeOrderTestCase {
//         ..mass_take_order_base_case(),
//         is_redeemer_correct: False,
//       },
//     )
//   let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
//   !virtual_dex_logic(
//     mock_oracle_policy_id(),
//     mock_emergency_token(),
//     ada_asset_class(),
//     mock_token_asset_class(),
//     dat,
//     red,
//     ctx,
//   )
// }

// test fail_mass_take_order_with_take_order_input_from_different_address() {
//   let input_utxo = mock_utxo_ref(52)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 500,
//     }
//   let red = MassTakeOrder { take_order_input: mock_utxo_ref(51) }
//   let tx =
//     mass_take_order_test(
//       MassTakeOrderTestCase {
//         ..mass_take_order_base_case(),
//         is_input_from_own_address: False,
//       },
//     )
//   let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
//   !virtual_dex_logic(
//     mock_oracle_policy_id(),
//     mock_emergency_token(),
//     ada_asset_class(),
//     mock_token_asset_class(),
//     dat,
//     red,
//     ctx,
//   )
// }

// type CancelOrderTestCase {
//   is_order_value_returned: Bool,
//   is_operation_key_signed: Bool,
// }

// fn cancel_order_base_case() {
//   CancelOrderTestCase {
//     is_order_value_returned: True,
//     is_operation_key_signed: True,
//   }
// }

// fn cancel_order_test(test_case: CancelOrderTestCase) {
//   let CancelOrderTestCase { is_order_value_returned, is_operation_key_signed } =
//     test_case
//   let inputs =
//     [mock_buy_ada_order_input(1, 1612000, 310_000_000)]
//   let outputs =
//     [
//       mock_post_trade_trade_account_output(
//         if is_order_value_returned {
//           mock_buy_ada_order_input(1, 1612000, 310_000_000).output.value
//         } else {
//           mock_buy_ada_order_input(1, 1612000, 310_000_000).output.value
//             |> add("", "", -1)
//         },
//       ),
//     ]
//   let extra_signatories =
//     if is_operation_key_signed {
//       [mock_operation_key()]
//     } else {
//       []
//     }
//   let reference_inputs =
//     [mock_oracle_ref_input()]
//   Transaction {
//     ..placeholder(),
//     inputs: inputs,
//     outputs: outputs,
//     reference_inputs: reference_inputs,
//     extra_signatories: extra_signatories,
//   }
// }

// test success_cancel_order() {
//   let input_utxo = mock_utxo_ref(51)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 310_000_000,
//     }
//   let red = CancelOrder
//   let tx = cancel_order_test(cancel_order_base_case())
//   let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
//   virtual_dex_logic(
//     mock_oracle_policy_id(),
//     mock_emergency_token(),
//     ada_asset_class(),
//     mock_token_asset_class(),
//     dat,
//     red,
//     ctx,
//   )
// }

// test fail_cancel_order_without_value_returned() {
//   let input_utxo = mock_utxo_ref(51)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 310_000_000,
//     }
//   let red = CancelOrder
//   let tx =
//     cancel_order_test(
//       CancelOrderTestCase {
//         ..cancel_order_base_case(),
//         is_order_value_returned: False,
//       },
//     )
//   let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
//   !virtual_dex_logic(
//     mock_oracle_policy_id(),
//     mock_emergency_token(),
//     ada_asset_class(),
//     mock_token_asset_class(),
//     dat,
//     red,
//     ctx,
//   )
// }

// test fail_cancel_order_without_operation_key_signed() {
//   let input_utxo = mock_utxo_ref(51)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 310_000_000,
//     }
//   let red = CancelOrder
//   let tx =
//     cancel_order_test(
//       CancelOrderTestCase {
//         ..cancel_order_base_case(),
//         is_operation_key_signed: False,
//       },
//     )
//   let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
//   !virtual_dex_logic(
//     mock_oracle_policy_id(),
//     mock_emergency_token(),
//     ada_asset_class(),
//     mock_token_asset_class(),
//     dat,
//     red,
//     ctx,
//   )
// }

// // type EmergencyCancelTestCase {
// //   is_emergency_token_burnt: Bool,
// // }

// test success_emergency_cancel() {
//   let output_reference = mock_utxo_ref(51)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 310_000_000,
//     }

//   let red = EmergencyCancel
//   let tx =
//     Transaction {
//       ..placeholder(),
//       mint: to_minted_value(
//         from_asset(
//           mock_emergency_token(),
//           get_emergency_token_name(mock_trade_account_address()),
//           -1,
//         ),
//       ),
//     }
//   let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
//   virtual_dex_logic(
//     mock_oracle_policy_id(),
//     mock_emergency_token(),
//     ada_asset_class(),
//     mock_token_asset_class(),
//     dat,
//     red,
//     ctx,
//   )
// }

// test fail_emergency_cancel_without_emergency_token_burnt() {
//   let output_reference = mock_utxo_ref(51)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 310_000_000,
//     }

//   let red = EmergencyCancel
//   let tx =
//     Transaction {
//       ..placeholder(),
//       mint: to_minted_value(
//         from_asset(
//           mock_emergency_token(),
//           get_emergency_token_name(mock_change_account_address()),
//           -1,
//         ),
//       ),
//     }
//   let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
//   !virtual_dex_logic(
//     mock_oracle_policy_id(),
//     mock_emergency_token(),
//     ada_asset_class(),
//     mock_token_asset_class(),
//     dat,
//     red,
//     ctx,
//   )
// }
