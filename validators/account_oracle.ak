use aiken/transaction.{ScriptContext}
use aiken_virtual_dex/types.{AccountOracleDatum, AccountOracleRedeemer}
use aiken_virtual_dex/validators/account_oracle.{account_oracle_logic}

validator {
  fn account_oracle(
    datum: AccountOracleDatum,
    redeemer: AccountOracleRedeemer,
    context: ScriptContext,
  ) {
    account_oracle_logic(datum, redeemer, context)
  }
}
