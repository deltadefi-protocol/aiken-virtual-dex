# Specification - Account

## Parameter

- `owner`: The pub key hash of account owner
- `user_unlock`: The script hash of `user_unlock` withdrawal script
- `app_unlock`: The script hash of `app_unlock` withdrawal script
- `emergency_unlock_phase1`: The script hash of `emergency_unlock_phase1` withdrawal script
- `emergency_unlock_phase2`: The script hash of `emergency_unlock_phase2` withdrawal script

## Datum

1. TradeNormalDatum

   - Stating that the UTxO is ready for normal app operation, including placing orders, taking orders and authorized withdrawal

2. TradeEmergencyDatum {valid_since, minter}

   - Stating that the UTxO is attached with an emergency token, ready for user withdrawal without passing through application logic

3. EmergencyIncidentInitiation {owner}

   - Stating that the UTxO is ready to be the authorization input for minting the emergency token.

## User Action

1. User Unlock - Redeemer `AccountUserUnlock`

   - Withdrawal script of `user_unlock` validating

2. App Unlock - Redeemer `AccountAppUnlock`

   - Withdrawal script of `app_unlock` validating

3. Emergency operation phase 1 - Redeemer `AccountEmergencyUnlockPhase1 {owner, initiate_before}`

   - Withdrawal script of `emergency_unlock_phase1` validating

4. Emergency operation phase 2 - Redeemer `AccountEmergencyUnlockPhase2 {owner, withdraw_output}`

   - Withdrawal script of `emergency_unlock_phase2` validating
