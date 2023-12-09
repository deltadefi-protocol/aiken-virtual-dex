# Specification - OracleNFT

## Parameter

- `utxo_ref`: UTxO to be spent at minting

## Datum

- `oracle_nft`: The policy id of `OracleNFT`
- `oracle_address`: The address of the current oracle validator
- `virtual_dex_script_hash`: The script hash (payment) information of the virtual dex
- `account_info_token`: The policy id of reference token on account
- `account_info_address`: The address of hosting account information in inline datum
- `emergency_token`: The policy id of the emergency token
- `account_count`: The current count of account created
- `operation_key`: The key for operation use. E.g. processing orders
- `stop_key`: The key for stopping the services

## User Action

1. Migrate Virtual Dex script - Redeemer `MigrateDex {new_virtual_dex_script_hash}`

   > To change the virtual dex script hash. Provide the new script hash from redeemer

   - 123

2. Rotate operation and stop keys - Redeemer `RotateKey {new_operation_key, new_stop_key}`

   - Only 1 out from oracle address
   - The output datum is updated with new operation key and stop key
   - Required signers include both original operation key and stop key

3. Stop the oracle validator - Redeemer `StopApp`

   - The transaction is signed by stop key
   - The `OracleNFT` is burnt
