use aiken/bytearray
use aiken/hash.{blake2b_256}
use aiken/transaction/credential.{
  Address, Inline, ScriptCredential, VerificationKeyCredential,
}

pub fn get_emergency_token_name(trade_account_address: Address) -> ByteArray {
  expect ScriptCredential(script_hash) =
    trade_account_address.payment_credential
  when trade_account_address.stake_credential is {
    None -> script_hash |> blake2b_256()
    Some(stake_cred) -> {
      expect Inline(credential) = stake_cred
      when credential is {
        VerificationKeyCredential(stake_hash) ->
          bytearray.concat(script_hash, stake_hash) |> blake2b_256()
        ScriptCredential(stake_hash) ->
          bytearray.concat(script_hash, stake_hash) |> blake2b_256()
      }
    }
  }
}
