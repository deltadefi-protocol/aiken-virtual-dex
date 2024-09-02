use aiken/hash.{Blake2b_224, Hash}
use aiken/pairs
use aiken/transaction.{ScriptContext, Transaction}
use aiken/transaction/credential.{Inline, Script, ScriptCredential}
use aiken/transaction/value.{AssetName}
use aiken_virtual_dex/types.{
  AccountAppUnlock, AccountDatum, AccountEmergencyUnlock, AccountRedeemer,
  AccountUserUnlock1, AccountUserUnlock2, EmergencyUnlockDatum,
}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_with}
use vodka_mints.{only_minted_token}
use vodka_outputs.{output_inline_datum}

validator(
  owner: ByteArray,
  user_unlock_1: Hash<Blake2b_224, Script>,
  user_unlock_2: Hash<Blake2b_224, Script>,
  app_unlock: Hash<Blake2b_224, Script>,
  emergency_token: AssetName,
) {
  pub fn account(
    _datum: AccountDatum,
    redeemer: AccountRedeemer,
    context: ScriptContext,
  ) -> Bool {
    let ScriptContext { transaction, .. } = context
    when redeemer is {
      AccountUserUnlock1 ->
        pairs.has_key(
          transaction.withdrawals,
          Inline(ScriptCredential(user_unlock_1)),
        )
      AccountUserUnlock2 ->
        pairs.has_key(
          transaction.withdrawals,
          Inline(ScriptCredential(user_unlock_2)),
        )
      AccountAppUnlock ->
        pairs.has_key(
          transaction.withdrawals,
          Inline(ScriptCredential(app_unlock)),
        )
      AccountEmergencyUnlock -> {
        let Transaction { extra_signatories, mint, inputs, .. } = transaction
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
}
