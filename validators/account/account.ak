use aiken/collection/pairs
use aiken/crypto.{ScriptHash}
use aiken_virtual_dex/types.{
  AccountAppUnlock, AccountDatum, AccountEmergencyUnlock, AccountRedeemer,
  AccountUserUnlock1, AccountUserUnlock2, EmergencyUnlockDatum,
}
use cardano/address.{Script}
use cardano/assets.{AssetName}
use cardano/transaction.{OutputReference, Transaction}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_with}
use vodka_mints.{only_minted_token}
use vodka_outputs.{output_inline_datum}

validator account(
  owner: ByteArray,
  user_unlock_1: ScriptHash,
  user_unlock_2: ScriptHash,
  app_unlock: ScriptHash,
  emergency_token: AssetName,
) {
  spend(
    _datum: Option<AccountDatum>,
    redeemer: AccountRedeemer,
    _input: OutputReference,
    tx: Transaction,
  ) {
    when redeemer is {
      AccountUserUnlock1 -> pairs.has_key(tx.withdrawals, Script(user_unlock_1))
      AccountUserUnlock2 -> pairs.has_key(tx.withdrawals, Script(user_unlock_2))
      AccountAppUnlock -> pairs.has_key(tx.withdrawals, Script(app_unlock))
      AccountEmergencyUnlock -> {
        let Transaction { extra_signatories, mint, inputs, .. } = tx
        let is_owner_signed = key_signed(extra_signatories, owner)
        let is_emergency_token_burnt =
          only_minted_token(mint, emergency_token, #"", -1)
        let emergency_input = inputs_with(inputs, emergency_token, #"")
        when emergency_input is {
          [only_input] -> {
            expect emergency_datum: EmergencyUnlockDatum =
              output_inline_datum(only_input.output)
            let is_emergency_owner_correct = emergency_datum.minter == owner
            is_owner_signed? && is_emergency_token_burnt? && is_emergency_owner_correct?
          }
          _ -> False
        }
      }
    }
  }

  else(_) {
    fail
  }
}
