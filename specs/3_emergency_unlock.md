# Specification - EmergencyUnlock

## Parameter

- `oracle_nft`: The policy id of account's `OracleNFT`

## Datum

- `minted_at`: The timestamp where the emergency withdraw buffer period start counting

## User Action

1. Unlock the emergency utxo

   - Only 1 reference utxo with `oracle_nft` with account oracle datum
   - If only 1 input with `emergency_token` & datum is in correct format
     - Yes: check if the `emergency_token` is burnt
     - No: required `operation_key` signature
