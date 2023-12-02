use aiken/transaction/credential.{Address}
use aiken/transaction/value.{PolicyId}

pub type MintPolarity {
  RMint
  RBurn
}

pub type OracleDatum {
  oracle_nft: PolicyId,
  oracle_address: Address,
  min_fee: Int,
  operation_key: ByteArray,
  stop_key: ByteArray,
}

pub type OracleRedeemer {
  UpdateFee { new_min_fee: Int }
  RotateKey { new_operation_key: ByteArray, new_stop_key: ByteArray }
  StopApp
}
