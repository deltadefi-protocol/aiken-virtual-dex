# Specification - TradeAccount

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`
- `count`: The account number

## Datum

1. TradeNormalDatum

   - Stating that the UTxO is ready for normal app operation, including placing orders, taking orders and authorized withdrawal

2. TradeEmergencyDatum {valid_since}

   - Stating that the UTxO is attached with an emergency token, ready for user withdrawal without passing through application logic

## User Action

1. Normal operation - Redeemer `TradeNormalAction`

   - Reference to oracle utxo
   - Reference to account info utxo
   - Signed by operation key & owner

2. Emergency operation - Redeemer `TradeEmergencyAction {withdraw_output}`

   - Reference to account info utxo
   - Signed by owner
   - Validity range is after `valid_since`
   - `EmergencyToken` is burnt in current transaction
