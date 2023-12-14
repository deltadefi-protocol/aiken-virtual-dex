use aiken/transaction.{OutputReference}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{AssetName, PolicyId}

// 1. OracleNFT
// 3. FeeRefToken
pub type MintPolarity {
  RMint
  RBurn
}

// 2. OracleValidator
pub type OracleDatum {
  oracle_nft: PolicyId,
  oracle_address: Address,
  fee_ref_token: PolicyId,
  fee_info_address: Address,
  operation_key: ByteArray,
  stop_key: ByteArray,
}

pub type OracleRedeemer {
  RotateKey { new_operation_key: ByteArray, new_stop_key: ByteArray }
  StopApp
}

// 4. FeeInfoValidator
pub type FeeInfoDatum {
  long_token: (PolicyId, AssetName),
  short_token: (PolicyId, AssetName),
  min_fee: Int,
  percentage_fee: Int,
}

pub type FeeInfoRedeemer {
  UpdateFee { new_min_fee: Int, new_percentage_fee: Int }
  RemoveFeeInfo
}

// 5. TradeAccount
pub type TradeAccountDatum {
  TradeNormalDatum
  TradeEmergencyDatum { valid_since: Int, minter: ByteArray }
  EmergencyIncidentInitiation { owner: Address }
}

pub type TradeAccountRedeemer {
  TradeNormalAction
  TradeEmergencyAction { withdraw_output: OutputReference }
  InitiateEmergencyIncident
}

// 6. ChangeAccount
pub type ChangeAccountDatum {
  ChangeAccountDatum
}

pub type ChangeAccountRedeemer {
  OwnerWithdraw
  AppRefill
  MassRefill { refill_output: OutputReference }
}

// 7. VirtualDex
pub type VirtualDexDatum {
  change_account_address: Address,
  trade_account_address: Address,
  buy_token: (PolicyId, AssetName),
  sell_token: (PolicyId, AssetName),
  price: Int,
  log_size: Int,
}

pub type VirtualDexRedeemer {
  TakeOrder { order_taker: Address }
  MassTakeOrder { take_order_input: OutputReference }
  CancelOrder
  EmergencyCancel
}

// 8. EmergencyToken
pub type EmergencyTokenMintingPolarity {
  EMint { current_timestamp: Int }
  EBurn
}
