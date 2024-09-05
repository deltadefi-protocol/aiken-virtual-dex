use aiken/crypto.{blake2b_256}
use aiken/primitive/bytearray
use cardano/address.{Address, Inline, Script, VerificationKey}

pub fn get_emergency_token_name(account_address: Address) -> ByteArray {
  expect Script(script_hash) = account_address.payment_credential
  when account_address.stake_credential is {
    None -> script_hash |> blake2b_256()
    Some(stake_cred) -> {
      expect Inline(credential) = stake_cred
      when credential is {
        VerificationKey(stake_hash) ->
          bytearray.concat(script_hash, stake_hash) |> blake2b_256()
        Script(stake_hash) ->
          bytearray.concat(script_hash, stake_hash) |> blake2b_256()
      }
    }
  }
}
