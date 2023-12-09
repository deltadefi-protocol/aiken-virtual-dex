use aiken/transaction.{OutputReference}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{AssetName, PolicyId}

// 1. OracleNFT
// 3. AccountRefToken
pub type MintPolarity {
  RMint
  RBurn
}

// 2. OracleValidator
pub type OracleDatum {
  oracle_nft: PolicyId,
  oracle_address: Address,
  virtual_dex_script_hash: ByteArray,
  account_info_token: PolicyId,
  account_info_address: Address,
  emergency_token: PolicyId,
  operation_key: ByteArray,
  stop_key: ByteArray,
}

pub type OracleRedeemer {
  // MigrateDex { new_virtual_dex_script_hash: ByteArray }  
  RotateKey { new_operation_key: ByteArray, new_stop_key: ByteArray }
  StopApp
}

// 4. AccountInfoValidator
pub type AccountInfoDatum {
  min_fee: Int,
  owner_pub_key: ByteArray,
  owner_stake_cred: Option<ByteArray>,
  change_account_address: Address,
  trade_account_address: Address,
}

// pub type AccountInfoDatum {
//   TradeInfo { min_fee: Int, change_account_address: Address }
//   OperationInfo { owner_address: Address, trade_account_address: Address }
// }

pub type AccountInfoRedeemer {
  UpdateFee { new_min_fee: Int }
  TransferAccount {
    new_owner_pub_key: ByteArray,
    new_owner_stake_cred: Option<ByteArray>,
  }
}

// 5. TradeAccount
pub type TradeAddressDatum {
  TradeNormalDatum
  TradeEmergencyDatum { valid_since: Int }
}

pub type TradeAddressRedeemer {
  TradeNormalAction
  TradeEmergencyAction { withdraw_output: OutputReference }
}

// 6. ChangeAccount
pub type ChangeAddressDatum {
  ChangeNormalDatum
  ChangeEmergencyDatum { valid_since: Int }
}

pub type ChangeAddressRedeemer {
  OwnerWithdraw
  AppRefill
  MassRefill { refill_output: OutputReference }
}

// 7. VirtualDex
pub type VirtualDexDatum {
  long_token: (PolicyId, AssetName),
  short_token: (PolicyId, AssetName),
  price: Int,
  is_lot_long: Bool,
  log_size: Int,
}

pub type VirtualDexRedeemer {
  TakeOrder
  CancelOrder
  MassTakeOrder { take_order_output: OutputReference }
}

// 8. EmergencyToken
pub type EmergencyTokenMintingPolarity {
  EMint { current_timestamp: Int }
  EBurn
}
