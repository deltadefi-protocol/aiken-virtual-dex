# Specification - VirtualDex

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`
- `emergency_token`: The policy id of the emergency token
- `param_long_token`: The long side of token in trading pairs
- `param_short_token`: The short side of token in trading pairs

## Datum

- `change_account_address`: The address of the change account number of the owner
- `trade_account_address`: The address of the trade account number of the owner
- `is_long`: If the current order is for buying long token (`buy_token`)
- `list_price_times_10k`: Order exchange in a rate of `list_price` \* `sell_lot_size` = quantity of `buy_token` looking for
- `sell_lot_size`: Quantity of `sell token` in this order

## User Action

1. Core logic of taking orders - Redeemer `TakeOrder {order_taker}`

   - Reference to oracle utxo
   - Accumulate proceeds supposed send to order creators, check output value to them
   - Signed by operation key

2. Bypassing check if any other redeemer is with the core logic - Redeemer `MassTakeOrder { take_order_input }`

   - The input provided by redeemer comes from same address ad own input
   - The input provided by redeemer is with correct redeemer of `TakeOrder`

3. Cancelling order which is mistakenly listed onchain - Redeemer `CancelOrder`

   - Whole value spent to `TradeAccount` with correct owner in datum
   - signed by both `operating_key` and owner

4. Emergency operation - Redeemer `EmergencyCancel`

   - `EmergencyToken` with token name hashing `trade_account_address` burnt in current transaction
