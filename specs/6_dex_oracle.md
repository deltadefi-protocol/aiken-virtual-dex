# Specification - DexOracle

## Parameter

## Datum

- `oracle_nft`: The policy id of `OracleNFT`
- `oracle_address`: The address of the current oracle validator
- `dex_address`: The address of the dex
- `operation_key`: The key for operation use. E.g. processing orders
- `stop_key`: The key for stopping the services

## User Action

1. Rotate operation and stop keys - Redeemer `DexRotateKey {new_operation_key, new_stop_key}`

   - Only 1 input from oracle address
   - The only 1 output datum is updated with new operation key and stop key
   - Required signers include both original and the new stop key

2. Stop the oracle validator - Redeemer `StopDex`

   - The transaction is signed by stop key
   - The `OracleNFT` is burnt
