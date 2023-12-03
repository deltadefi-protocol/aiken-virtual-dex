use aiken/transaction.{OutputReference}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{AssetName, PolicyId}

pub type MintPolarity {
  RMint
  RBurn
}

pub type OracleDatum {
  oracle_nft: PolicyId,
  oracle_address: Address,
  virtual_dex_address: Address,
  trade_account_address: Address,
  change_account_address: Address,
  min_fee: Int,
  operation_key: ByteArray,
  stop_key: ByteArray,
}

pub type OracleRedeemer {
  UpdateFee { new_min_fee: Int }
  RotateKey { new_operation_key: ByteArray, new_stop_key: ByteArray }
  StopApp
}

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

pub type ChangeAddressDatum {
  owner: ByteArray,
}

pub type ChangeAddressRedeemer {
  OwnerWithdraw
  AppRefill
  MassRefill { refill_output: OutputReference }
}

pub type TradeAddressDatum {
  TradeUtxo
  WithdrawUtxo
}

pub type TradeAddressRedeemer {
  PlaceOrder
  TradeWithdrawal { withdraw_output: OutputReference }
}
