# Specification - TradeAccount

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`
- `owner`: The pub key has of account owner
- `fee_ref_token`: The policy id of `FeeRefToken`

## Datum

1. TradeNormalDatum

   - Stating that the UTxO is ready for normal app operation, including placing orders, taking orders and authorized withdrawal

2. TradeEmergencyDatum {valid_since}

   - Stating that the UTxO is attached with an emergency token, ready for user withdrawal without passing through application logic

3. InitiateEmergencyIncident {owner}

   - Stating that the UTxO is ready to be the authorization input for minting the emergency token.

## User Action

1. Normal operation - Redeemer `TradeNormalAction`

   - Reference to oracle utxo
   - Signed by operation key & owner

2. Emergency operation - Redeemer `TradeEmergencyAction {withdraw_output}`

   - Signed by owner
   - Validity range is after `valid_since`
   - `EmergencyToken` with correct token name of hash of current address is burnt in current transaction

3. Emergency operation - Redeemer `InitiateEmergencyIncident`

   - Signed by owner
   - Emergency token is minted, with minting redeemer checked
   - `EmergencyToken` with correct token name of hash of current address is burnt in current transaction
