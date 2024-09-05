# Specification - EmergencyToken

## Parameter

- `emergency_unlock_address`: The output address locking the emergency token

## User Action

1. Mint - Redeemer `EMint { minter }`

   - Must be signed by owner
   - There is only 1 token minted (current policy), with token name encoded owner
   - There must be 1 output to `emergency_unlock_address`
   - The output datum to `emergency_unlock_address` with `minted_at` information
   - The transaction must be before `minted_at`

2. Burn - Redeemer `EBurn`

   - Only 1 input from `emergency_unlock_address`, with current policy token and with token name encoded owner
   - The current policy id only has negative minting value in transaction body.
   - The current signing interval has `validity_interval_start` with `86400` slots after `valid_since` plus owner signature. Or The current signing interval has `validity_interval_start` with `172800` slots after `valid_since`.
