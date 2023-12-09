# Specification - OracleNFT

## Parameter

- `utxo_ref`: UTxO to be spent at minting

## User Action

1. Mint - Redeemer `EMint {current_timestamp}`

   - Reference to account utxo
   - There must be 1 output to `TradeAccount`
   - The output datum to `TradeAccount` with `valid_since` after current signing interval
   - Must be signed by owner

2. Burn - Redeemer `RBurn`

   - The current policy id only has negative minting value in transaction body.
