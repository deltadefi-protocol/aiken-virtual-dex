use aiken_virtual_dex/types.{AccountOracleDatum}
use cardano/assets.{PolicyId}
use cardano/certificate.{RegisterCredential}
use cardano/script_context.{Publishing, ScriptContext, Withdrawing}
use cardano/transaction.{Transaction}
use vodka_extra_signatories.{all_key_signed}
use vodka_inputs.{only_input_datum_with}

validator account_user_unlock(oracle_nft: PolicyId, owner: ByteArray) {
  // withdraw(_redeemer: Data, _credential: Credential, tx: Transaction) {
  //   let Transaction { reference_inputs, extra_signatories, .. } = tx
  //   expect AccountOracleDatum { operation_key, .. }: AccountOracleDatum =
  //     only_input_datum_with(reference_inputs, oracle_nft, "")
  //   all_key_signed(extra_signatories, [owner, operation_key])
  // }

  // publish(_redeemer: Data, _certificate: Certificate, tx: Transaction) {
  //   let Transaction { reference_inputs, extra_signatories, .. } = tx
  //   expect AccountOracleDatum { operation_key, .. }: AccountOracleDatum =
  //     only_input_datum_with(reference_inputs, oracle_nft, "")
  //   all_key_signed(extra_signatories, [owner, operation_key])
  // }

  // else(_) {
  //   fail
  // }

  else(ctx: ScriptContext) {
    when ctx.info is {
      Withdrawing(_) -> {
        let Transaction { reference_inputs, extra_signatories, .. } =
          ctx.transaction
        expect AccountOracleDatum { operation_key, .. }: AccountOracleDatum =
          only_input_datum_with(reference_inputs, oracle_nft, "")
        all_key_signed(extra_signatories, [owner, operation_key])
      }
      Publishing(_at, cert) ->
        when cert is {
          RegisterCredential(..) -> {
            let Transaction { reference_inputs, extra_signatories, .. } =
              ctx.transaction
            expect AccountOracleDatum { operation_key, .. }: AccountOracleDatum =
              only_input_datum_with(reference_inputs, oracle_nft, "")
            all_key_signed(extra_signatories, [owner, operation_key])
          }
          _ -> fail
        }
      _ -> fail
    }
  }
}
