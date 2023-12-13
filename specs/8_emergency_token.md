# Specification - OracleNFT

## Parameter

- `owner`: The pub key has of account owner

## User Action

1. Mint - Redeemer `EMint {current_timestamp, trade_account_address}`

   - The `AssetName` must be in form of hash of `ValidatorHash` + `StakeCredentialHash`
   - There must be 1 output to `trade_account_address`
   - The output datum to `trade_account_address` with `valid_since` after current signing interval
   - Must be signed by owner

2. Burn - Redeemer `EBurn`

   - The current policy id only has negative minting value in transaction body.
