// type EmergencyActionTestCase {
//   is_owner_signed: Bool,
//   is_input_datum_correct: Bool,
//   is_time_valid: Bool,
//   is_emergency_token_burnt: Bool,
// }

// fn base_emergency_action_test_case() {
//   EmergencyActionTestCase {
//     is_owner_signed: True,
//     is_input_datum_correct: True,
//     is_time_valid: True,
//     is_emergency_token_burnt: True,
//   }
// }

// fn mock_emergency_action_test_case(test_case: EmergencyActionTestCase) {
//   let EmergencyActionTestCase {
//     is_owner_signed,
//     is_input_datum_correct,
//     is_time_valid,
//     is_emergency_token_burnt,
//   } = test_case

//   let extra_signatories =
//     when is_owner_signed is {
//       True ->
//         [mock_user_vkey_hex()]
//       False ->
//         []
//     }
//   let emergency_action_input =
//     if is_input_datum_correct {
//       mock_emergency_action_input(1, 100, mock_user_vkey_hex())
//     } else {
//       mock_emergency_action_input(1, 100, mock_operation_key())
//     }
//   let inputs =
//     [mock_trade_input(1), mock_trade_input(2), emergency_action_input]
//   let mint =
//     to_minted_value(
//       if is_emergency_token_burnt {
//         from_asset(
//           mock_emergency_token(),
//           get_emergency_token_name(mock_trade_account_address()),
//           -1,
//         )
//       } else {
//         zero()
//       },
//     )
//   let validity_range =
//     mock_interval(
//       Some(
//         if is_time_valid {
//           101
//         } else {
//           99
//         },
//       ),
//       None,
//     )
//   Transaction {
//     ..placeholder(),
//     mint: mint,
//     extra_signatories: extra_signatories,
//     validity_range: validity_range,
//     inputs: inputs,
//   }
// }

// test success_emergency_withdraw() {
//   let output_reference = mock_utxo_ref(0, 31)
//   let datum =
//     TradeEmergencyDatum { valid_since: 100, minter: mock_user_vkey_hex() }

//   let redeemer = TradeEmergencyAction { withdraw_output: output_reference }
//   let tx = mock_emergency_action_test_case(base_emergency_action_test_case())
//   let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
//   trade_account_logic(
//     mock_oracle_policy_id(),
//     mock_user_vkey_hex(),
//     mock_emergency_token(),
//     datum,
//     redeemer,
//     ctx,
//   )
// }

// test fail_emergency_withdraw_without_owner_signature() {
//   let output_reference = mock_utxo_ref(0, 31)
//   let datum =
//     TradeEmergencyDatum { valid_since: 100, minter: mock_user_vkey_hex() }

//   let redeemer = TradeEmergencyAction { withdraw_output: output_reference }
//   let tx =
//     mock_emergency_action_test_case(
//       EmergencyActionTestCase {
//         ..base_emergency_action_test_case(),
//         is_owner_signed: False,
//       },
//     )
//   let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
//   !trade_account_logic(
//     mock_oracle_policy_id(),
//     mock_user_vkey_hex(),
//     mock_emergency_token(),
//     datum,
//     redeemer,
//     ctx,
//   )
// }

// test fail_emergency_withdraw_with_invalid_time() {
//   let output_reference = mock_utxo_ref(0, 31)
//   let datum =
//     TradeEmergencyDatum { valid_since: 100, minter: mock_user_vkey_hex() }

//   let redeemer = TradeEmergencyAction { withdraw_output: output_reference }
//   let tx =
//     mock_emergency_action_test_case(
//       EmergencyActionTestCase {
//         ..base_emergency_action_test_case(),
//         is_time_valid: False,
//       },
//     )
//   let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
//   !trade_account_logic(
//     mock_oracle_policy_id(),
//     mock_user_vkey_hex(),
//     mock_emergency_token(),
//     datum,
//     redeemer,
//     ctx,
//   )
// }

// test fail_emergency_withdraw_without_emergency_token_burnt() {
//   let output_reference = mock_utxo_ref(0, 31)
//   let datum =
//     TradeEmergencyDatum { valid_since: 100, minter: mock_user_vkey_hex() }

//   let redeemer = TradeEmergencyAction { withdraw_output: output_reference }
//   let tx =
//     mock_emergency_action_test_case(
//       EmergencyActionTestCase {
//         ..base_emergency_action_test_case(),
//         is_emergency_token_burnt: False,
//       },
//     )
//   let ctx = ScriptContext { purpose: Spend(output_reference), transaction: tx }
//   !trade_account_logic(
//     mock_oracle_policy_id(),
//     mock_user_vkey_hex(),
//     mock_emergency_token(),
//     datum,
//     redeemer,
//     ctx,
//   )
// }
