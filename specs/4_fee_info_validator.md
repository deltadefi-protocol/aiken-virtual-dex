# Specification - FeeInfoValidator

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`

## Datum

- `token_1`: (PolicyId, AssetName),
- `token_2`: (PolicyId, AssetName),
- `min_fee`: Int,
- `percentage_fee`: Int,

## User Action

1. Update minimum fee needed - Redeemer `UpdateFee {new_min_fee, new_percentage_fee}`

   - Reference to oracle utxo
   - 1 input & 1 output with current address
   - Empty minting info
   - Signed by operation key
   - Datum of re-spend utxo updated
   - `FeeRefToken` re-spend into current address with clean utxo (length of 2)

2. Burn the `FeeRefToken` and remove fee info - Redeemer `RemoveFeeInfo`

   - Reference to oracle utxo
   - `fee_ref_token` is burnt
   - No output to current validator
   - Signed by and `operation_key`
