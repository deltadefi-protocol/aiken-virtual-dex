# List of Smart Contracts

There are in total 7 scripts for the DeltaDeFi virtual dex to work. Below provide description and pointers to a more detailed specs.

1. OracleNFT

- The one time minting policy, minting the NFT to be reference token locking in `OracleValidator`. It is used for serving static app information.

2. OracleValidator

- The validator locking `OracleNFT`, for serving app static information while protecting information integrity.

3. AccountRefToken

- The reference token sitting in `AccountInfoValidator`, serving user account information.

4. AccountInfoValidator

- The validator locking `AccountRefToken`, for serving user account information while protecting information integrity.

5. Trade Account

- The script to be compiled into different addresses according to account number, storing the UTxO ready for place order.

6. Change Account

- The script to be compiled into different addresses according to account number, storing the change UTxO after transaction.

7. Virtual DEX

- The script governing the transaction logic.
