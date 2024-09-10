use aiken_virtual_dex/types.{AccountOracleDatum}
use cardano/address.{Credential}
use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction}
use cardano/certificate.{Certificate}
use vodka_extra_signatories.{all_key_signed}
use vodka_inputs.{only_input_datum_with}

validator account_user_unlock(oracle_nft: PolicyId, owner: ByteArray) {
  withdraw(_redeemer: Data, _credential: Credential, tx: Transaction) {
    expect AccountOracleDatum { operation_key, .. }: AccountOracleDatum =
      only_input_datum_with(tx.reference_inputs, oracle_nft, "")
    all_key_signed(tx.extra_signatories, [owner, operation_key])
  }

  publish(redeemer: Data, certificate: Certificate, tx: Transaction) {
    True
    // account_user_unlock.withdraw(oracle_nft, owner, redeemer, certificate, tx)
  }

  else(_) {
    fail
  }
}
