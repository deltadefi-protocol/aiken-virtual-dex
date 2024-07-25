use aiken/transaction.{Input, Mint, ScriptContext, Transaction, placeholder}
use aiken/transaction/value.{
  PolicyId, add, from_asset, from_lovelace, to_minted_value,
}
use aiken_virtual_dex/types.{RBurn, RMint}
use aiken_virtual_dex/validators/oracle_nft.{oracle_nft_logic}
use sidan_placeholder/address.{mock_pub_key_address}
use sidan_placeholder/key_hex.{mock_policy_id}
use sidan_placeholder/output_reference.{mock_utxo_ref}
use sidan_placeholder/outputs.{mock_pub_key_output}

test success_mint() {
  let redeemer = RMint
  let input_utxo = mock_utxo_ref(0, 1)
  let policy_id: PolicyId =
    #"1c1b7afe8affbee1505cf3ec5a58bd2734d4ffdfcc9b9f059625bd76"

  let tx =
    Transaction {
      ..placeholder(),
      mint: to_minted_value(from_asset(policy_id, "", 1)),
      inputs: [
        Input {
          output_reference: input_utxo,
          output: mock_pub_key_output(
            mock_pub_key_address(0, None),
            from_lovelace(1000000),
          ),
        },
      ],
    }
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }

  oracle_nft_logic(input_utxo, redeemer, ctx)
}

test fail_mint_no_utxo_ref_supply() {
  let redeemer = RMint
  let policy_id = mock_policy_id(0)

  let ctx =
    ScriptContext { purpose: Mint(policy_id), transaction: placeholder() }

  !oracle_nft_logic(mock_utxo_ref(0, 0), redeemer, ctx)
}

test success_burn() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    Transaction {
      ..placeholder(),
      mint: to_minted_value(from_asset(policy_id, "", -1)),
    }
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  oracle_nft_logic(mock_utxo_ref(0, 0), redeemer, ctx)
}

test success_burn_with_other_minting() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    Transaction {
      ..placeholder(),
      mint: to_minted_value(
        from_asset(policy_id, "", -1) |> add(mock_policy_id(1), "", 1),
      ),
    }
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  oracle_nft_logic(mock_utxo_ref(0, 0), redeemer, ctx)
}

test fail_burn_with_mint() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    Transaction {
      ..placeholder(),
      mint: to_minted_value(from_asset(policy_id, "", 1)),
    }
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !oracle_nft_logic(mock_utxo_ref(0, 0), redeemer, ctx)
}

test fail_burn_with_mix() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    Transaction {
      ..placeholder(),
      mint: to_minted_value(
        from_asset(policy_id, "", -1) |> add(policy_id, "1", 1),
      ),
    }
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  !oracle_nft_logic(mock_utxo_ref(0, 0), redeemer, ctx)
}
