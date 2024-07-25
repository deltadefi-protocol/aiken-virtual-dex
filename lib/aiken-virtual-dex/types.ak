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

// 3. EmergencyToken
pub type EmergencyTokenMintingPolarity {
  EMint { current_timestamp: Int, account_address: Address }
  EBurn
}

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

// 5. VirtualDex
pub type VirtualDexDatum {
  account_address: Address,
  is_long: Bool,
  list_price_times_1mil: Int,
  lot_size: Int,
  extra_lovelace: Int,
}

pub type VirtualDexRedeemer {
  TakeOrders
  CancelOrder
  EmergencyCancel
}
