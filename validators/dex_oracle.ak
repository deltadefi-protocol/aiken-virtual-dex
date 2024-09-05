use aiken_virtual_dex/types.{
  DexOracleDatum, DexOracleRedeemer, DexRotateKey, StopDex,
}
use cardano/transaction.{InlineDatum, Output, OutputReference, Transaction}
use vodka_extra_signatories.{all_key_signed, key_signed}
use vodka_mints.{only_minted_token}
use vodka_outputs.{outputs_at_with}

validator dex_oracle {
  spend(
    datum_opt: Option<DexOracleDatum>,
    redeemer: DexOracleRedeemer,
    _input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction { outputs, mint, extra_signatories, .. } = tx
    expect Some(datum) = datum_opt
    let DexOracleDatum { oracle_nft, oracle_address, stop_key, .. } = datum

    when redeemer is {
      DexRotateKey { new_operation_key, new_stop_key } -> {
        expect [own_output] =
          outputs_at_with(outputs, oracle_address, oracle_nft, "")
        expect InlineDatum(dat) = own_output.datum
        expect own_datum: DexOracleDatum = dat
        let datum_correct =
          own_datum == DexOracleDatum {
            ..datum,
            operation_key: new_operation_key,
            stop_key: new_stop_key,
          }
        all_key_signed(extra_signatories, [new_stop_key, stop_key]) && datum_correct
      }

      StopDex ->
        key_signed(extra_signatories, stop_key) && only_minted_token(
          mint,
          oracle_nft,
          "",
          -1,
        )
    }
  }

  else(_) {
    fail
  }
}
