# Specification - VirtualDex

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`
- `emergency_token`: The policy id of the emergency token
- `order_script_hash`: The script hash of the withdrawal script needed for taking order

## Datum

- `change_account_address`: The address of the change account number of the owner
- `trade_account_address`: The address of the trade account number of the owner
- `is_long`: If the current order is for buying long token (`buy_token`)
- `list_price_times_10k`: Order exchange in a rate of `list_price` \* `lot_size` = quantity of `param_short_token`
- `lot_size`: Quantity of `sell token` in this order

## User Action

1. Core logic of taking order - Redeemer `TakeOrder`

   - Current transaction is validating a withdrawal script as param

2. Cancelling order which is mistakenly listed onchain - Redeemer `CancelOrder`

   - Whole value spent to `TradeAccount` with correct owner in datum
   - signed by both `operating_key` and owner

3. Emergency operation - Redeemer `EmergencyCancel`

- `EmergencyToken` with token name hashing `trade_account_address` burnt in current transaction
