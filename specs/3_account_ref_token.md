# Specification - AccountRefToken

## Parameter

- `utxo_ref`: UTxO to be spent at minting

## User Action

1. Mint - Redeemer `CreateAccount {all datum fields in AccountInfoDatum}`

   - 1 input from oracle validator
   - The token name minted is calculated through current count
   - 1 output to `AccountInfoValidator`, value length of 2
   - Signed by both operation key and `owner_pub_key`

2. Burn - Redeemer `AccountRefTokenBurn`

   - The current policy id only has negative minting value in transaction body.
