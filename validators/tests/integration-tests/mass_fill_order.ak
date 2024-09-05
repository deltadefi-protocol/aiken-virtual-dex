use account/account
use account/user_unlock
use aiken/collection/list
use aiken_virtual_dex/placeholder.{
  ada_asset_class, mock_account_address, mock_account_oracle_policy_id,
  mock_account_oracle_ref_input, mock_buy_ada_order_input,
  mock_dex_oracle_policy_id, mock_dex_oracle_ref_input, mock_emergency_token,
  mock_fee_output, mock_operation_key, mock_post_trade_account_output,
  mock_token_asset_class, mock_trade_input, mock_user_vkey_hex, script_hash_5_1,
  script_hash_5_2, script_hash_6_1,
}
use aiken_virtual_dex/types.{
  AccountDatum, AccountRedeemer, AccountUserUnlock1, TakeOrders, VirtualDexDatum,
  VirtualDexRedeemer,
}
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

fn account_process(index: Int, tx: Transaction, redeemer: AccountRedeemer) {
  let input = mock_utxo_ref(0, index)
  account.account.spend(
    mock_user_vkey_hex(),
    script_hash_5_1(),
    script_hash_5_1(),
    script_hash_5_2(),
    mock_emergency_token(),
    Some(AccountDatum),
    redeemer,
    input,
    tx,
  )
}

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

fn add_buy_ada_order_inputs(
  tx: Transaction,
  count: Int,
  token_lot_size: Int,
  ada_lot_size: Int,
  extra_lovelace: Int,
  fee_lovelace: Int,
) -> Transaction {
  let list_price_times_1mil = ada_lot_size * 1000000 / token_lot_size
  let count_list = list.range(1, count)
  list.foldr(
    count_list,
    tx,
    fn(index, tx_acc) {
      tx_acc
        |> add_input(
            True,
            mock_buy_ada_order_input(
              50 + index,
              list_price_times_1mil,
              token_lot_size,
              extra_lovelace,
              fee_lovelace,
            ),
          )
    },
  )
}

fn take_order_test(buy_count: Int) -> Transaction {
  let token_lot_size = 310_000_000
  let ada_lot_size = 500_000_000
  let min_fee = 2_000_000
  let percentage_fee_times_10k = 5
  let extra_lovelace = 4_750_000
  let fee_per_limit_order = 250_000

  let to_maker = ( ada_lot_size + extra_lovelace ) * buy_count

  let count_list = list.range(1, buy_count)

  let tx =
    mocktail_tx()
      |> required_signer_hash(True, mock_user_vkey_hex())
      |> script_withdrawal(True, script_hash_5_1(), 0)
      |> script_withdrawal(True, script_hash_5_1(), 0)
      |> required_signer_hash(True, mock_operation_key())
      |> complete()
      |> add_reference_input(True, mock_dex_oracle_ref_input())
      |> add_reference_input(True, mock_account_oracle_ref_input())
      |> add_output(
          True,
          mock_fee_output(ada_lot_size * 3, min_fee, percentage_fee_times_10k),
        )
      |> add_output(
          True,
          mock_post_trade_account_output(from_asset("", "", to_maker)),
        )
      |> add_buy_ada_order_inputs(
          buy_count,
          token_lot_size,
          ada_lot_size,
          extra_lovelace,
          fee_per_limit_order,
        )
  list.foldr(
    count_list,
    tx,
    fn(index, tx_acc) {
      tx_acc
        |> add_input(True, mock_trade_input(index))
        |> add_input(True, mock_trade_input(index + 50))
    },
  )
}

fn mass_virtual_dex_processing(
  count: Int,
  tx: Transaction,
  dat: VirtualDexDatum,
) {
  let count_list = list.range(1, count)
  list.foldr(
    count_list,
    True,
    fn(index, acc) { acc && virtual_dex_process(index, tx, dat, TakeOrders) },
  )
}

fn mass_account_utxo_processing(count: Int, tx: Transaction) {
  let count_list = list.range(1, count)
  list.foldr(
    count_list,
    True,
    fn(index, acc) {
      acc && account_process(index, tx, AccountUserUnlock1) && account_process(
        index + 50,
        tx,
        AccountUserUnlock1,
      )
    },
  )
}

test integration_test_mass_take_orders() {
  let number_of_orders = 10

  let dat =
    VirtualDexDatum {
      account_address: mock_account_address(),
      is_long: True,
      list_price_times_1mil: 60000,
      lot_size: 500,
      extra_lovelace: 0,
    }
  let tx = take_order_test(number_of_orders)
  mass_account_utxo_processing(number_of_orders, tx) && mass_virtual_dex_processing(
    number_of_orders,
    tx,
    dat,
  ) && take_orders.virtual_dex_take_orders.withdraw(
    mock_dex_oracle_policy_id(),
    ada_asset_class(),
    mock_token_asset_class(),
    Void,
    Script(script_hash_6_1()),
    tx,
  ) && user_unlock.account_user_unlock.withdraw(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    Void,
    Script(script_hash_5_1()),
    tx,
  )
}
