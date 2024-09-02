# List of Smart Contracts

There are in total 6 scripts for the DeltaDeFi virtual dex to work. Below provide description and pointers to a more detailed specs.

1. OracleNFT - [specification](./1_oracle_nft.md)

   - The one time minting policy, minting the NFT to be reference token locking in `OracleValidator`. It is used for serving static app information.

2. EmergencyToken - [specification](./2_emergency_token.md)

   - The minting policy for taking any withdrawal / cancel actions solely by users.

3. EmergencyUnlockValidator - [specification](./3_emergency_unlock.md)

   - The validator locking emergency token for withdrawal bypassing multi-sig

4. AccountOracle - [specification](./4_account_oracle.md)

   - The validator locking `OracleNFT`, for serving app static information on `Account` while protecting information integrity.

5. Account - [specification](./5_account/5_account.md)

   - The script to be compiled into different addresses according to account number, storing the UTxO ready for place order.
   - Action specification:
     - 4.1: User Unlock - [specification](./5_account/5.1_user_unlock.md)
     - 4.2: App Unlock - [specification](./5_account/5.2_app_unlock.md)
     - 4.3: Emergency Unlock Phase 2- [specification](./5_account/5.3_emergency_unlock_phase2.md)

6. DexOracle - [specification](./6_account_oracle.md)

   - The validator locking a specific `OracleNFT`, for serving app static information on `VirtualDEX` while protecting information integrity.

7. VirtualDEX - [specification](./7_virtual_dex/6_virtual_dex.md)

   - The script governing the transaction logic.
   - Action specification:
     - 5.1: Take Orders - [specification](./7_virtual_dex/7.1_take_orders.md)

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
