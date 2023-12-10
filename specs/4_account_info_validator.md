# Specification - AccountInfoValidator

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`

## Datum

- `min_fee`: Minimum fee to pay for matching order in lovelace
- `owner_pub_key`: The payment key of owner
- `owner_stake_cred`: The stake credential of owner
- `change_account_address`: The change account address of the account owner
- `trade_account_address`: The trade account address of the account owner

## User Action

1. Update minimum fee needed - Redeemer `UpdateFee {new_min_fee}`

   - Reference to oracle utxo
   - 1 input & 1 output with current address
   - Signed by operation key
   - Datum of re-spend utxo updated
   - `AccountRefToken` re-spend into current address with clean utxo

2. Transfer the account to other address - Redeemer `TransferAccount {new_owner_pub_key, new_owner_stake_cred}`

   - Signed by original pub key
   - 1 input & 1 output with current address
   - Datum of re-spend utxo updated
   - `AccountRefToken` re-spend into current address with clean utxo

3. Delete the account - Redeemer `DeleteAccount`

   - Reference to oracle utxo
   - 1 input & 1 output with current address
   - Signed by both owner and `operation_key`
