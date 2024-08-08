use aiken/transaction.{Mint, ScriptContext, placeholder}
use aiken/transaction/value.{PolicyId, from_lovelace}
use aiken_virtual_dex/types.{RBurn, RMint}
use mocktail.{complete, mint, mocktail_tx, tx_in}
use mocktail/virgin_address.{mock_pub_key_address}
use mocktail/virgin_key_hex.{mock_policy_id}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}
use oracle_nft.{oracle_nft}

test success_mint() {
  let redeemer = RMint
  let input_utxo = mock_utxo_ref(0, 1)
  let policy_id: PolicyId =
    #"1c1b7afe8affbee1505cf3ec5a58bd2734d4ffdfcc9b9f059625bd76"

  let tx =
    mocktail_tx()
      |> mint(True, 1, policy_id, "")
      |> tx_in(
          True,
          mock_tx_hash(0),
          1,
          from_lovelace(1000000),
          mock_pub_key_address(0, None),
        )
      |> complete()

  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }

  oracle_nft(input_utxo, redeemer, ctx)
}

test fail_mint_no_utxo_ref_supply() {
  let redeemer = RMint
  let policy_id = mock_policy_id(0)

  let ctx =
    ScriptContext { purpose: Mint(policy_id), transaction: placeholder() }

  !oracle_nft(mock_utxo_ref(0, 0), redeemer, ctx)
}

test success_burn() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    mocktail_tx()
      |> mint(True, -1, policy_id, "")
      |> complete()

  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  oracle_nft(mock_utxo_ref(0, 0), redeemer, ctx)
}

test success_burn_with_other_minting() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    mocktail_tx()
      |> mint(True, -1, policy_id, "")
      |> mint(True, -1, mock_policy_id(1), "")
      |> complete()
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  oracle_nft(mock_utxo_ref(0, 0), redeemer, ctx)
}

test fail_burn_with_mint() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    mocktail_tx()
      |> mint(True, 1, policy_id, "")
      |> complete()

  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !oracle_nft(mock_utxo_ref(0, 0), redeemer, ctx)
}

test fail_burn_with_mix() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    mocktail_tx()
      |> mint(True, -1, policy_id, "")
      |> mint(True, 1, policy_id, "1")
      |> complete()

  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !oracle_nft(mock_utxo_ref(0, 0), redeemer, ctx)
}
