use aiken/transaction.{Input, OutputReference}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{PolicyId}

// 1. OracleNFT
pub type MintPolarity {
  RMint
  RBurn
}

// 2. OracleValidator
pub type OracleDatum {
  oracle_nft: PolicyId,
  oracle_address: Address,
  operation_key: ByteArray,
  stop_key: ByteArray,
}

pub type OracleRedeemer {
  RotateKey { new_operation_key: ByteArray, new_stop_key: ByteArray }
  StopApp
}

// 3. TradeAccount
pub type TradeAccountDatum {
  TradeNormalDatum
  TradeEmergencyDatum { valid_since: Int, minter: ByteArray }
  EmergencyIncidentInitiation { owner: ByteArray }
}

pub type TradeAccountRedeemer {
  TradeNormalAction
  TradeEmergencyAction { withdraw_output: OutputReference }
  InitiateEmergencyIncident { initiate_before: Int }
}

// 4. ChangeAccount
pub type ChangeAccountDatum {
  ChangeAccountDatum
}

pub type ChangeAccountRedeemer {
  OwnerWithdraw
  AppRefill
  MassRefill { refill_input: OutputReference }
}

// 5. VirtualDex
pub type VirtualDexDatum {
  change_account_address: Address,
  trade_account_address: Address,
  is_long: Bool,
  list_price_times_1mil: Int,
  lot_size: Int,
}

pub type VirtualDexRedeemer {
  TakeOrder
  MassTakeOrder { take_order_input: OutputReference }
  CancelOrder
  EmergencyCancel
}

// 6. EmergencyToken
pub type EmergencyTokenMintingPolarity {
  EMint { current_timestamp: Int, trade_account_address: Address }
  EBurn
}

// New Types

// 3. Account
pub type AccountRedeemer {
  AccountUserUnlock
  AccountAppUnlock
  AccountEmergencyUnlockPhase1
  AccountEmergencyUnlockPhase2
}

pub type AccountDatum {
  AccountNormalDatum
  EmergencyUnlockPhase1 { owner: ByteArray }
  EmergencyUnlockPhase2 { valid_since: Int, minter: ByteArray }
}

pub type AccountEmergencyActionPhase1Redeemer {
  owner: ByteArray,
  own_input: Input,
  initiate_before: Int,
}

pub type AccountEmergencyActionPhase2Redeemer {
  owner: ByteArray,
  own_input: Input,
  withdraw_output: OutputReference,
}
