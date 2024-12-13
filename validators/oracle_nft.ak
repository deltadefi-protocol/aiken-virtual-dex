use aiken/collection/list
use aiken_virtual_dex/types.{MintPolarity, RBurn, RMint}
use cardano/assets.{PolicyId}
use cardano/transaction.{Input, OutputReference, Transaction}
use vodka_mints.{check_policy_only_burn, only_minted_token}

validator oracle_nft(utxo_ref: OutputReference) {
  mint(redeemer: MintPolarity, policy_id: PolicyId, tx: Transaction) {
    when redeemer is {
      RMint -> {
        let Transaction { inputs, mint, .. } = tx
        let hash_equal =
          fn(input: Input) {
            let hash = input.output_reference
            utxo_ref == hash
          }
        let target_input_exist = list.any(inputs, hash_equal)
        let check_only_minted_token = only_minted_token(mint, policy_id, #"", 1)
        target_input_exist && check_only_minted_token
      }
      RBurn -> check_policy_only_burn(tx.mint, policy_id)
    }
  }

  else(_) {
    fail
  }
}
