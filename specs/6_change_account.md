# Specification - ChangeAccount

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`
- `count`: The account number

## Datum

1. ChangeNormalDatum

   - Stating that the UTxO is ready for normal app operation, including placing orders, taking orders and authorized withdrawal

2. ChangeEmergencyDatum {valid_since}

   - Stating that the UTxO is attached with an emergency token, ready for user withdrawal without passing through application logic

## User Action

1. Owner withdraws the amount from change address - Redeemer `OwnerWithdraw`

   - Reference to account info utxo
   - Signed by operation owner

2. Core logic of auto refill without user action - Redeemer `AppRefill`

   - Reference to account info utxo
   - Value send to both change account and trade account is greater than input value from change account

3. Bypassing check if any other redeemer is with the core logic - Redeemer `MassRefill { refill_output }`

   - The output provided by redeemer is with correct redeemer of `AppRefill`
