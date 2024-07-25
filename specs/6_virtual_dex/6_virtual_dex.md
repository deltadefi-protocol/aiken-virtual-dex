# Specification - VirtualDex

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`
- `emergency_token`: The policy id of the emergency token
- `take_orders`: The script hash of `take_orders` withdrawal script

## Datum

- `account_address`: The address of the account number of the owner
- `is_long`: If the current order is for buying long token (`buy_token`)
- `list_price_times_10k`: Order exchange in a rate of `list_price` \* `lot_size` = quantity of `param_short_token`
- `lot_size`: Quantity of `sell token` in this order
- `extra_lovelace`: The extra lovelace provided in the utxo, to be returned to `Account`

## User Action

1. Core logic of taking orders - Redeemer `TakeOrders`

   - Withdrawal script of `take_orders` validating

2. Cancelling order which is mistakenly listed onchain - Redeemer `CancelOrder`

   - Whole value spent to `Account` with correct owner in datum
   - signed by both `operating_key` and owner

3. Emergency operation - Redeemer `EmergencyCancel`

   - `EmergencyToken` with token name hashing `trade_account_address` burnt in current transaction
