# Specification - FeeRefToken

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`

## User Action

1. Mint - Redeemer RMint

   - Only 1 `FeeToken` is minted with empty token name
   - 1 output to `FeeInfoValidator`, value length of 2
   - The inline datum attached with the output is in format of `FeeInfoDatum`
   - Signed by both operation key and `owner_pub_key`
   - Datum should be equivalent with `account_count + 1`

2. Burn - Redeemer RBurn

   - The current policy id only has negative minting value in transaction body.
