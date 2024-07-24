// use aiken/dict.{Dict}
// use aiken/list
// use aiken/transaction.{
//   Input, Output, Redeemer, ScriptContext, ScriptPurpose, Spend, Transaction,
//   placeholder,
// }
// use aiken/transaction/value.{from_asset}
// use aiken_virtual_dex/common.{compare_output_reference}
// use aiken_virtual_dex/placeholder.{
//   ada_asset_class, mock_buy_ada_order_input, mock_change_account_address,
//   mock_emergency_token, mock_fee_output, mock_operation_key, mock_oracle_address,
//   mock_oracle_policy_id, mock_oracle_ref_input,
//   mock_post_trade_trade_account_output, mock_token_asset_class,
//   mock_trade_account_address, mock_utxo_ref,
// }
// use aiken_virtual_dex/types.{MassTakeOrder, TakeOrder, VirtualDexDatum}
// use aiken_virtual_dex/validators/virtual_dex.{virtual_dex_logic}

// type TakeOrderTestCase {
//   is_token_paid_to_maker: Bool,
//   is_operation_key_signed: Bool,
//   is_input_from_own_address: Bool,
//   is_redeemer_correct: Bool,
// }

// fn take_order_base_case() {
//   TakeOrderTestCase {
//     is_token_paid_to_maker: True,
//     is_operation_key_signed: True,
//     is_input_from_own_address: True,
//     is_redeemer_correct: True,
//   }
// }

// fn generate_mock_inputs(
//   count: Int,
//   price: Int,
//   token_lot_size: Int,
// ) -> List<Input> {
//   if count == 0 {
//     []
//   } else {
//     generate_mock_inputs(count - 1, price, token_lot_size)
//       |> list.push(mock_buy_ada_order_input(count + 1, price, token_lot_size))
//   }
// }

// // fn generate_mock_redeemers(
// //   count: Int,
// //   red: Data,
// // ) -> Dict<ScriptPurpose, Redeemer> {
// //   if count == 0 {
// //     dict.new()
// //   } else {
// //     generate_mock_redeemers(count - 1, red)
// //       |> dict.insert(
// //            Spend(mock_utxo_ref(0,51 + count)),
// //            red,
// //            compare_output_reference,
// //          )
// //   }
// // }

// // fn mock_order_inputs_with_redeemers(
// //   count: Int,
// //   ada_lot_size,
// //   token_lot_size,
// //   is_input_from_own_address,
// //   is_redeemer_correct,
// // ) -> (List<Input>, Dict<ScriptPurpose, Redeemer>) {
// //   let price = ada_lot_size * 1_000_000 / token_lot_size
// //   let inputs =
// //     [
// //       if is_input_from_own_address {
// //         mock_buy_ada_order_input(1, price, 310_000_000)
// //       } else {
// //         Input {
// //           output_reference: mock_utxo_ref(0,51),
// //           output: Output {
// //             ..mock_buy_ada_order_input(1, 1612000, 310_000_000).output,
// //             address: mock_oracle_address(),
// //           },
// //         }
// //       },
// //     ]
// //       |> list.concat(generate_mock_inputs(count - 1, price, token_lot_size))
// //   let mass_take_order_red: Data =
// //     MassTakeOrder { take_order_input: mock_utxo_ref(0,51) }
// //   let take_order_red: Data = TakeOrder
// //   let redeemers =
// //     dict.new()
// //       |> dict.insert(
// //           Spend(mock_utxo_ref(0,51)),
// //           if is_redeemer_correct {
// //             take_order_red
// //           } else {
// //             mass_take_order_red
// //           },
// //           compare_output_reference,
// //         )
// //       |> dict.union(
// //           generate_mock_redeemers(count - 1, mass_take_order_red),
// //           compare_output_reference,
// //         )
// //   (inputs, redeemers)
// // }

// fn take_order_test(test_case: TakeOrderTestCase, count: Int) {
//   let TakeOrderTestCase {
//     is_token_paid_to_maker,
//     is_operation_key_signed,
//     is_input_from_own_address,
//     is_redeemer_correct,
//   } = test_case
//   let token_lot_size = 310_000_000
//   let ada_lot_size = 499_999_930
//   let min_fee = 2_000_000

//   let percentage_fee_times_10k = 5
//   let fee_output =
//     mock_fee_output(ada_lot_size * count, min_fee, percentage_fee_times_10k)

//   let reference_inputs =
//     [mock_oracle_ref_input()]
//   let extra_signatories =
//     if is_operation_key_signed {
//       [mock_operation_key()]
//     } else {
//       []
//     }
//   let to_user_output =
//     mock_post_trade_trade_account_output(
//       from_asset(
//         "",
//         "",
//         if is_token_paid_to_maker {
//           ada_lot_size * count
//         } else {
//           ada_lot_size * count - 1
//         },
//       ),
//     )
//   let outputs =
//     [fee_output, to_user_output]
//   let (inputs, redeemers) =
//     mock_order_inputs_with_redeemers(
//       count,
//       ada_lot_size,
//       token_lot_size,
//       is_input_from_own_address,
//       is_redeemer_correct,
//     )
//   Transaction {
//     ..placeholder(),
//     reference_inputs: reference_inputs,
//     extra_signatories: extra_signatories,
//     inputs: inputs,
//     outputs: outputs,
//     redeemers: redeemers,
//   }
// }

// fn generate_mass_take_order_evaluation(
//   count: Int,
//   tx: Transaction,
//   param_virtual_dex,
// ) -> Bool {
//   if count == 0 {
//     True
//   } else {
//     param_virtual_dex(
//       MassTakeOrder { take_order_input: mock_utxo_ref(0,51) },
//       ScriptContext {
//         purpose: Spend(mock_utxo_ref(0,51 + count)),
//         transaction: tx,
//       },
//     ) && generate_mass_take_order_evaluation(count - 1, tx, param_virtual_dex)
//   }
// }

// test success_mass_take_order_integration_test() {
//   let count = 20
//   let input_utxo = mock_utxo_ref(0,51)
//   let dat =
//     VirtualDexDatum {
//       change_account_address: mock_change_account_address(),
//       trade_account_address: mock_trade_account_address(),
//       is_long: True,
//       list_price_times_1mil: 60000,
//       lot_size: 500,
//     }
//   let red = TakeOrder
//   let tx = take_order_test(take_order_base_case(), count)
//   let ctx = ScriptContext { purpose: Spend(input_utxo), transaction: tx }
//   let param_virtual_dex =
//     virtual_dex_logic(
//       mock_oracle_policy_id(),
//       mock_emergency_token(),
//       ada_asset_class(),
//       mock_token_asset_class(),
//       dat,
//       _,
//       _,
//     )

//   param_virtual_dex(red, ctx) && generate_mass_take_order_evaluation(
//     count - 1,
//     tx,
//     param_virtual_dex,
//   )
// }
