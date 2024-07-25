// use aiken/transaction.{
//   InlineDatum, Input, Output, ScriptContext, Transaction, WithdrawFrom,
// }
// use aiken/transaction/credential.{Inline, ScriptCredential}
// use aiken/transaction/value.{from_asset}
// use aiken_virtual_dex/placeholder.{
//   ada_asset_class, mock_account_address, mock_buy_ada_order_input,
//   mock_fee_output, mock_operation_key, mock_oracle_address,
//   mock_oracle_policy_id, mock_oracle_ref_input, mock_post_trade_account_output,
//   mock_token_asset_class, script_hash_5_1,
// }
// use aiken_virtual_dex/types.{TakeOrders, VirtualDexDatum}
// use aiken_virtual_dex/validators/virtual_dex/take_orders.{
//   virtual_dex_take_orders_logic,
// }
// use sidan_placeholder/builder.{
//   complete, new_tx_tester, required_signer_hash, script_withdrawal,
// }
// use sidan_placeholder/output_reference.{mock_utxo_ref}
// use sidan_placeholder/transaction.{add_input,
//   add_output, add_reference_input} as sidan_transaction
// use tests/unit_tests/virtual_dex/virtual_dex.{virtual_dex_process} as tvirtual_dex

// fn add_buy_ada_order_inputs(tx: Transaction, count: Int) -> Transaction {
//   todo
// }

// fn take_order_test(buy_count: Int, sell_count: Int) -> Transaction {
//   let token_lot_size = 310_000_000
//   let ada_lot_size = 500_000_000
//   let min_fee = 2_000_000
//   let list_price_times_1mil = ada_lot_size * 1000000 / token_lot_size
//   let percentage_fee_times_10k = 5

//   new_tx_tester()
//     |> script_withdrawal(True, script_hash_5_1(), 0)
//     |> required_signer_hash(True, mock_operation_key())
//     |> complete()
//     |> add_reference_input(True, mock_oracle_ref_input())
//     |> add_output(
//         True,
//         mock_fee_output(ada_lot_size * 3, min_fee, percentage_fee_times_10k),
//       )
//     |> add_output(
//         True,
//         mock_post_trade_account_output(from_asset("", "", ada_lot_size * 3)),
//       )
//     |> add_input(
//         True,
//         mock_buy_ada_order_input(1, list_price_times_1mil, ada_lot_size, 0),
//       )
//     |> add_input(
//         True,
//         mock_buy_ada_order_input(2, list_price_times_1mil, ada_lot_size, 0),
//       )
//     |> add_input(
//         True,
//         mock_buy_ada_order_input(3, list_price_times_1mil, ada_lot_size, 0),
//       )
// }
