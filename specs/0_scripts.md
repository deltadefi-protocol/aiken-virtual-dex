# List of Smart Contracts

There are in total 7 scripts for the DeltaDeFi virtual dex to work. Below provide description and pointers to a more detailed specs.

1. OracleNFT - [specification](./1_oracle_nft.md)

   - The one time minting policy, minting the NFT to be reference token locking in `OracleValidator`. It is used for serving static app information.

2. OracleValidator - [specification](./2_oracle_validator.md)

   - The validator locking `OracleNFT`, for serving app static information while protecting information integrity.

3. AccountRefToken - [specification](./3_account_ref_token.md)

   - The reference token sitting in `AccountInfoValidator`, serving user account information.

4. AccountInfoValidator - [specification](./4_account_info_validator.md)

   - The validator locking `AccountRefToken`, for serving user account information while protecting information integrity.

5. TradeAccount - [specification](./5_trade_account.md)

   - The script to be compiled into different addresses according to account number, storing the UTxO ready for place order.

6. ChangeAccount - [specification](./6_change_account.md)

   - The script to be compiled into different addresses according to account number, storing the change UTxO after transaction.

7. VirtualDEX

   - The script governing the transaction logic.

8. EmergencyToken

   - The minting policy for taking any withdrawal / cancel actions solely by users.
