use aiken/transaction.{InlineDatum, Output, ScriptContext, Spend, Transaction}
use aiken_virtual_dex/types.{
  AccountOracleDatum, AccountOracleRedeemer, RotateKey, StopApp,
}
use sidan_utils/extra_signatories.{all_key_signed, key_signed}
use sidan_utils/mints.{only_minted_token}
use sidan_utils/outputs.{outputs_at_with}

pub fn account_oracle_logic(
  datum: AccountOracleDatum,
  redeemer: AccountOracleRedeemer,
  context: ScriptContext,
) {
  let ScriptContext { purpose, transaction } = context
  when purpose is {
    Spend(_) -> {
      let Transaction { outputs, mint, extra_signatories, .. } = transaction
      let AccountOracleDatum { oracle_nft, oracle_address, stop_key, .. } =
        datum

      when redeemer is {
        RotateKey { new_operation_key, new_stop_key } -> {
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

        StopApp ->
          key_signed(extra_signatories, stop_key) && only_minted_token(
            mint,
            oracle_nft,
            "",
            -1,
          )
      }
    }
    _ -> False
  }
}
