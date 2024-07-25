# List of Smart Contracts

There are in total 6 scripts for the DeltaDeFi virtual dex to work. Below provide description and pointers to a more detailed specs.

1. OracleNFT - [specification](./1_oracle_nft.md)

   - The one time minting policy, minting the NFT to be reference token locking in `OracleValidator`. It is used for serving static app information.

2. OracleValidator - [specification](./2_oracle_validator.md)

   - The validator locking `OracleNFT`, for serving app static information while protecting information integrity.

3. EmergencyToken - [specification](./3_emergency_token.md)

   - The minting policy for taking any withdrawal / cancel actions solely by users.

4. Account - [specification](./4_account/4_account.md)

   - The script to be compiled into different addresses according to account number, storing the UTxO ready for place order.
   - Action specification:
     - 4.1: User Unlock - [specification](./4_account/4.1_user_unlock.md)
     - 4.2: App Unlock - [specification](./4_account/4.2_app_unlock.md)
     - 4.3: Emergency Unlock Phase 1 - [specification](./4_account/4.3_emergency_unlock_phase1.md)
     - 4.4: Emergency Unlock Phase 2- [specification](./4_account/4.4_emergency_unlock_phase2.md)

5. VirtualDEX - [specification](./5_virtual_dex/5_virtual_dex.md)

   - The script governing the transaction logic.
   - Action specification:
     - 5.1: Take Orders - [specification](./5_virtual_dex/5.1_take_orders.md)
     - 5.2: Cancel Order - [specification](./5_virtual_dex/5.2_cancel_order.md)
     - 5.3: Emergency Cancel - [specification](./5_virtual_dex/5.3_emergency_cancel.md)

## Param Dependency Graph

1. First layer

   - 1.1 `EmergencyToken` (no param)
   - 1.2 `OracleNFT` (param: `utxo_ref`)
   - 1.3 `OracleValidator` (no param)

2. Second layer

   - 2.1 All account actions (param: `owner`, 1.1, 1.2)
   - 2.2 All dex actions (param: 1.1, 1.2)

3. Third layer

   - 3.1 `Account` (param: 2.1)
   - 3.2 `VirtualDEX` (param: 2.2)
