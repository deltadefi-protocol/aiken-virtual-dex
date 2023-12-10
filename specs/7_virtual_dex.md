# Specification - VirtualDex

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`

## Datum

- `account_number`: The account number of owner of order
- `long_token`: The `AssetClass` of token in long side
- `short_token`: The `AssetClass` of token in short side
- `price`: Order exchange in a rate of `price` \* `long token` = `short token`
- `is_lot_long`: If the user is selling short token for long token
- `log_size`: Quantity of `long token` in this order

## User Action

1. Core logic of taking orders - Redeemer `TakeOrder {order_taker}`

   - Reference to oracle utxo
   - Reference to account info utxo of ann account owners
   - Accumulate proceeds supposed send to order creators, check output value to them
   - Cumulated amount send to `order_taker`
   - Signed by operation owner

2. Bypassing check if any other redeemer is with the core logic - Redeemer `MassTakeOrder { take_order_output }`

   - The output provided by redeemer is with correct redeemer of `TakeOrder`

3. Cancelling order which is mistakenly listed onchain - Redeemer `CancelOrder`

   - Whole value spent to `TradeAccount` with correct owner in datum
   - signed by both `operating_key` and owner

4. Emergency operation - Redeemer `EmergencyCancel`

   - Reference to account info utxo
   - `EmergencyToken` is burnt in current transaction
