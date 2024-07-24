use aiken_virtual_dex/placeholder.{mock_utxo_ref}
use aiken_virtual_dex/validators/account/account.{AccountUserUnlock}

test t3_1_success() {
  let redeemer = AccountUserUnlock
  let output_reference = mock_utxo_ref(1)

  let tx = mint_test_case(base_test_case())
  let ctx = ScriptContext { purpose: Mint(policy_id), transaction: tx }
  emergency_token_logic(redeemer, ctx)
}
