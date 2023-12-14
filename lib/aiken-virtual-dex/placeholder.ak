use aiken/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, TransactionId,
}
use aiken/transaction/credential.{
  Address, Credential, ScriptCredential, VerificationKeyCredential,
}
use aiken/transaction/value.{PolicyId, add, from_asset, from_lovelace}
use aiken_virtual_dex/types.{FeeInfoDatum, OracleDatum}

pub fn mock_policy_id() -> PolicyId {
  #"1c1b7afe8affbee1505cf3ec5a58bd2734d4ffdfcc9b9f059625bd76"
}

pub fn mock_policy_id_2() -> PolicyId {
  #"52e322a5dd87fe977c5ee5b91e3f42eedeccd6795a7ef4f158bd8892"
}

pub fn mock_policy_id_3() -> PolicyId {
  #"a15cd6051ea2fc92c034b0bb1d33f2b7ba7ac92277e6ee5c30ab19a4"
}

pub fn mock_policy_id_4() -> PolicyId {
  #"c0f778be07f8b129d2546ad37b0e13b3486747dfe1767ff8e7e8a4f3"
}

pub fn mock_policy_id_5() -> PolicyId {
  #"ab4e38cc1e95e42c6f6e56d8d4243731c483bb57e49da5047c38e9d8"
}

pub fn mock_utxo_ref(output_index: Int) -> OutputReference {
  OutputReference {
    transaction_id: TransactionId(
      #"5a077cbcdffb88b104f292aacb9687ce93e2191e103a30a0cc5505c18b719f98",
    ),
    output_index,
  }
}

pub fn mock_output() -> Output {
  Output {
    address: Address {
      payment_credential: VerificationKeyCredential(""),
      stake_credential: None,
    },
    value: from_lovelace(1000000),
    datum: NoDatum,
    reference_script: None,
  }
}

// Pub Key Addresses

pub fn mock_vkey_hex() -> ByteArray {
  #"a2c20c77887ace1cd986193e4e75babd8993cfd56995cd5cfce609c2"
}

pub fn mock_verfication_key_credential() -> Credential {
  VerificationKeyCredential(mock_vkey_hex())
}

pub fn mock_pub_key_address(stake_credential) -> Address {
  Address {
    payment_credential: mock_verfication_key_credential(),
    stake_credential,
  }
}

pub fn mock_vkey_hex_2() -> ByteArray {
  #"e2cfca46ecdf7feb8a3a7f957ead86b88c156f3fdd9607bcb44eb8f5"
}

pub fn mock_verfication_key_credential_2() -> Credential {
  VerificationKeyCredential(mock_vkey_hex_2())
}

pub fn mock_pub_key_address_2(stake_credential) -> Address {
  Address {
    payment_credential: mock_verfication_key_credential_2(),
    stake_credential,
  }
}

pub fn mock_vkey_hex_3() -> ByteArray {
  #"310b3e52ee714c92f723d4e3e4060fc8029f13f672872eefa742a716"
}

pub fn mock_verfication_key_credential_3() -> Credential {
  VerificationKeyCredential(mock_vkey_hex_3())
}

pub fn mock_pub_key_address_3(stake_credential) -> Address {
  Address {
    payment_credential: mock_verfication_key_credential_3(),
    stake_credential,
  }
}

// Script Addresses

pub fn mock_script_hex() -> ByteArray {
  #"70ce90786897b6f7b6430a57ae005ecaf7c8cab817dd7510598403a9"
}

pub fn mock_script_credential() -> Credential {
  ScriptCredential(mock_script_hex())
}

pub fn mock_script_address(stake_credential) -> Address {
  Address {
    payment_credential: ScriptCredential(mock_script_hex()),
    stake_credential,
  }
}

pub fn mock_script_hex_2() -> ByteArray {
  #"efa5288b2b13cff1db555eed5debc54f3b25a62b7321db37f8af9213"
}

pub fn mock_script_credential_2() -> Credential {
  ScriptCredential(mock_script_hex_2())
}

pub fn mock_script_address_2(stake_credential) -> Address {
  Address {
    payment_credential: ScriptCredential(mock_script_hex_2()),
    stake_credential,
  }
}

pub fn mock_script_hex_3() -> ByteArray {
  #"a8ba4d8ab8d7f1f864a27a63dab1185cc47929dc3c3a34956d946286"
}

pub fn mock_script_credential_3() -> Credential {
  ScriptCredential(mock_script_hex_3())
}

pub fn mock_script_address_3(stake_credential) -> Address {
  Address {
    payment_credential: ScriptCredential(mock_script_hex_3()),
    stake_credential,
  }
}

// Smart contract specific placeholders
pub fn mock_oracle_policy_id() {
  mock_policy_id()
}

pub fn mock_oracle_address() {
  mock_script_address(None)
}

pub fn mock_fee_ref_token() {
  mock_policy_id_2()
}

pub fn mock_fee_info_address() {
  mock_script_address_2(None)
}

pub fn mock_operation_key() {
  mock_vkey_hex()
}

pub fn mock_stop_key() {
  mock_vkey_hex_2()
}

pub fn mock_oracle_datum() {
  OracleDatum {
    oracle_nft: mock_oracle_policy_id(),
    oracle_address: mock_oracle_address(),
    fee_ref_token: mock_fee_ref_token(),
    fee_info_address: mock_fee_info_address(),
    operation_key: mock_operation_key(),
    stop_key: mock_stop_key(),
  }
}

pub fn mock_oracle_output(oracle_datum: OracleDatum) -> Output {
  Output {
    address: mock_oracle_address(),
    value: from_asset(mock_oracle_policy_id(), "", 1)
      |> add(#"", #"", 2_000_000),
    datum: InlineDatum(oracle_datum),
    reference_script: None,
  }
}

pub fn mock_oracle_ref_input() -> Input {
  Input {
    output_reference: mock_utxo_ref(0),
    output: mock_oracle_output(mock_oracle_datum()),
  }
}

pub fn mock_fee_ref_output() -> Output {
  Output {
    address: mock_fee_info_address(),
    value: from_asset(mock_fee_ref_token(), "", 1) |> add("", "", 2_000_000),
    datum: InlineDatum(
      FeeInfoDatum {
        long_token: ("", ""),
        short_token: (mock_policy_id_5(), "A potentially very long name"),
        min_fee: 0,
        percentage_fee: 0,
      },
    ),
    reference_script: None,
  }
}
