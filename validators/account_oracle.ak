use aiken/transaction.{InlineDatum, Output, ScriptContext, Spend, Transaction}
use aiken_virtual_dex/types.{
  AccountOracleDatum, AccountOracleRedeemer, RotateKey,
}
use vodka_extra_signatories.{all_key_signed}
use vodka_outputs.{outputs_at_with}

validator {
  pub fn account_oracle(
    datum: AccountOracleDatum,
    redeemer: AccountOracleRedeemer,
    context: ScriptContext,
  ) {
    let ScriptContext { purpose, transaction } = context
    when purpose is {
      Spend(_) -> {
        let Transaction { outputs, extra_signatories, .. } = transaction
        let AccountOracleDatum { oracle_nft, oracle_address, stop_key, .. } =
          datum

        let RotateKey { new_operation_key, new_stop_key } = redeemer
        expect [own_output] =
          outputs_at_with(outputs, oracle_address, oracle_nft, "")
        expect InlineDatum(dat) = own_output.datum
        expect own_datum: AccountOracleDatum = dat
        let datum_correct =
          own_datum == AccountOracleDatum {
            ..datum,
            operation_key: new_operation_key,
            stop_key: new_stop_key,
          }
        all_key_signed(extra_signatories, [new_stop_key, stop_key]) && datum_correct
      }
      _ -> False
    }
  }
}
