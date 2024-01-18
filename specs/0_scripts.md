# List of Smart Contracts

There are in total 7 scripts for the DeltaDeFi virtual dex to work. Below provide description and pointers to a more detailed specs.

1. OracleNFT - [specification](./1_oracle_nft.md)

   - The one time minting policy, minting the NFT to be reference token locking in `OracleValidator`. It is used for serving static app information.

2. OracleValidator - [specification](./2_oracle_validator.md)

   - The validator locking `OracleNFT`, for serving app static information while protecting information integrity.

3. TradeAccount - [specification](./3_trade_account.md)

   - The script to be compiled into different addresses according to account number, storing the UTxO ready for place order.

4. ChangeAccount - [specification](./4_change_account.md)

   - The script to be compiled into different addresses according to account number, storing the change UTxO after transaction.

5. VirtualDEX - [specification](./5_virtual_dex.md)

   - The script governing the transaction logic.

6. EmergencyToken - [specification](./6_emergency_token.md)

   - The minting policy for taking any withdrawal / cancel actions solely by users.

## Param Dependency Graph

1. First layer

   - 1.1 `EmergencyToken` (no param)
   - 1.2 `OracleNFT` (param: `utxo_ref`)
   - 1.3 `OracleValidator` (no param)

2. Second layer

   - 2.1`TradeAccount` (param: `owner`, 1.1, 1.2)
   - 2.2 `VirtualDEX` (param: 1.1, 1.2)

3. Third layer
   - 3.1 `ChangeAccount` (param: `owner`, 1.2, 2.1)
