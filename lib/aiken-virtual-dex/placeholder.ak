use aiken/interval.{
  Finite, Interval, IntervalBound, NegativeInfinity, PositiveInfinity,
}
use aiken/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, TransactionId,
  ValidityRange,
}
use aiken/transaction/credential.{
  Address, Credential, ScriptCredential, StakeCredential,
  VerificationKeyCredential,
}
use aiken/transaction/value.{PolicyId, Value, add, from_asset, from_lovelace}
use aiken_virtual_dex/types.{
  ChangeAccountDatum, EmergencyIncidentInitiation, OracleDatum,
  TradeEmergencyDatum, TradeNormalDatum, VirtualDexDatum,
}
use aiken_virtual_dex/utils.{get_emergency_token_name}

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

pub fn mock_pub_key_hex(variation: Int) -> ByteArray {
  when variation is {
    1 -> #"a2c20c77887ace1cd986193e4e75babd8993cfd56995cd5cfce609c2"
    2 -> #"e2cfca46ecdf7feb8a3a7f957ead86b88c156f3fdd9607bcb44eb8f5"
    _ -> #"310b3e52ee714c92f723d4e3e4060fc8029f13f672872eefa742a716"
  }
}

pub fn mock_verfication_key_credential(variation: Int) -> Credential {
  VerificationKeyCredential(mock_pub_key_hex(variation))
}

pub fn mock_pub_key_address(variation: Int, stake_credential) -> Address {
  Address {
    payment_credential: mock_verfication_key_credential(variation),
    stake_credential,
  }
}

pub fn mock_interval(lower: Option<Int>, upper: Option<Int>) -> ValidityRange {
  let lower_bound =
    when lower is {
      Some(lower_bound_number) ->
        IntervalBound {
          bound_type: Finite(lower_bound_number),
          is_inclusive: True,
        }
      None -> IntervalBound { bound_type: NegativeInfinity, is_inclusive: True }
    }
  let upper_bound =
    when upper is {
      Some(upper_bound_number) ->
        IntervalBound {
          bound_type: Finite(upper_bound_number),
          is_inclusive: True,
        }
      None -> IntervalBound { bound_type: PositiveInfinity, is_inclusive: True }
    }

  Interval { lower_bound, upper_bound }
}

// Script Addresses

pub fn mock_script_hash_hex(variation: Int) -> ByteArray {
  when variation is {
    1 -> #"70ce90786897b6f7b6430a57ae005ecaf7c8cab817dd7510598403a9"
    2 -> #"efa5288b2b13cff1db555eed5debc54f3b25a62b7321db37f8af9213"
    3 -> #"a8ba4d8ab8d7f1f864a27a63dab1185cc47929dc3c3a34956d946286"
    4 -> #"ee557be73b5084e8907e2118a2b1cddf3a1e14dcb2e1ee5d586a3f90"
    5 -> #"84944ba25d1708d71058ee2ef715375873784adc588f6a0706fa2589"
    6 -> #"8be60057c65fbae6d5c0673f899fea68868b16aeba6ff06f2d7f3161"
    _ -> #"e9fbf88caff6bf3742fd30047abf3883d50ed7059ae832fddfda4b71"
  }
}

pub fn mock_script_credential(variation: Int) -> Credential {
  ScriptCredential(mock_script_hash_hex(variation))
}

pub fn mock_script_address(
  variation: Int,
  stake_credential: Option<StakeCredential>,
) -> Address {
  Address {
    payment_credential: mock_script_credential(variation),
    stake_credential,
  }
}

// Smart contract specific placeholders
pub fn mock_oracle_policy_id() -> PolicyId {
  mock_policy_id()
}

pub fn mock_oracle_address() {
  mock_script_address(1, None)
}

pub fn mock_fee_ref_token() {
  mock_policy_id_2()
}

pub fn mock_fee_info_address() {
  mock_script_address(2, None)
}

pub fn mock_operation_key() {
  mock_pub_key_hex(1)
}

pub fn mock_stop_key() {
  mock_pub_key_hex(2)
}

pub fn mock_emergency_token() {
  mock_policy_id_3()
}

pub fn mock_user_vkey_hex() {
  mock_pub_key_hex(3)
}

pub fn mock_user_address() {
  mock_pub_key_address(3, None)
}

pub fn ada_asset_class() {
  ("", "")
}

pub fn mock_token_asset_class() {
  (mock_policy_id_5(), "A potentially very long name")
}

pub fn mock_oracle_datum() {
  OracleDatum {
    oracle_nft: mock_oracle_policy_id(),
    oracle_address: mock_oracle_address(),
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

pub fn mock_trade_account_address() {
  mock_script_address(3, None)
}

pub fn mock_trade_output(lovelace: Int) -> Output {
  Output {
    address: mock_trade_account_address(),
    value: from_asset("", "", lovelace),
    datum: InlineDatum(TradeNormalDatum),
    reference_script: None,
  }
}

pub fn mock_trade_input(variation: Int) -> Input {
  Input {
    output_reference: mock_utxo_ref(10 + variation),
    output: mock_trade_output(500_000_000),
  }
}

pub fn mock_emergency_initiation_output(owner: ByteArray) -> Output {
  Output {
    address: mock_trade_account_address(),
    value: from_asset("", "", 2_000_000),
    datum: InlineDatum(EmergencyIncidentInitiation { owner }),
    reference_script: None,
  }
}

pub fn mock_emergency_initiation_input(variation: Int) -> Input {
  Input {
    output_reference: mock_utxo_ref(20 + variation),
    output: mock_emergency_initiation_output(mock_user_vkey_hex()),
  }
}

pub fn mock_emergency_action_output(valid_since: Int, minter: ByteArray) {
  Output {
    address: mock_trade_account_address(),
    value: from_asset("", "", 2_000_000)
      |> add(
           mock_emergency_token(),
           get_emergency_token_name(mock_trade_account_address()),
           1,
         ),
    datum: InlineDatum(TradeEmergencyDatum { valid_since, minter }),
    reference_script: None,
  }
}

pub fn mock_emergency_action_input(
  variation: Int,
  valid_since: Int,
  minter: ByteArray,
) -> Input {
  Input {
    output_reference: mock_utxo_ref(30 + variation),
    output: mock_emergency_action_output(valid_since, minter),
  }
}

pub fn mock_user_output(value: Value) -> Output {
  Output {
    address: mock_user_address(),
    value,
    datum: NoDatum,
    reference_script: None,
  }
}

pub fn mock_change_account_address() {
  mock_script_address(4, None)
}

pub fn mock_change_output(lovelace: Int) -> Output {
  Output {
    address: mock_change_account_address(),
    value: from_asset("", "", lovelace),
    datum: InlineDatum(ChangeAccountDatum),
    reference_script: None,
  }
}

pub fn mock_change_input(variation: Int, lovelace: Int) -> Input {
  Input {
    output_reference: mock_utxo_ref(40 + variation),
    output: Output {
      address: mock_change_account_address(),
      value: from_asset("", "", lovelace),
      datum: InlineDatum(ChangeAccountDatum),
      reference_script: None,
    },
  }
}

pub fn mock_fee_address() {
  mock_pub_key_address(1, None)
}

pub fn mock_fee_output(
  long_token_quantity: Int,
  min_fee: Int,
  percentage_fee_times_10k: Int,
) -> Output {
  let percentage_fee = long_token_quantity * percentage_fee_times_10k / 10000
  let fee_in_lovelace =
    if percentage_fee > min_fee {
      percentage_fee
    } else {
      min_fee
    }
  Output {
    address: mock_fee_address(),
    value: from_asset("", "", fee_in_lovelace),
    datum: NoDatum,
    reference_script: None,
  }
}

pub fn mock_virtual_dex_address() {
  mock_script_address(5, None)
}

pub fn mock_buy_ada_order_input(
  variation: Int,
  list_price_times_1mil: Int,
  sell_lot_size: Int,
) {
  Input {
    output_reference: mock_utxo_ref(50 + variation),
    output: Output {
      address: mock_virtual_dex_address(),
      value: from_asset(
        mock_token_asset_class().1st,
        mock_token_asset_class().2nd,
        sell_lot_size,
      ),
      datum: InlineDatum(
        VirtualDexDatum {
          change_account_address: mock_change_account_address(),
          trade_account_address: mock_trade_account_address(),
          is_long: True,
          list_price_times_1mil,
          sell_lot_size,
        },
      ),
      reference_script: None,
    },
  }
}

pub fn mock_sell_ada_order_input(
  variation: Int,
  list_price_times_1mil: Int,
  sell_lot_size: Int,
) {
  Input {
    output_reference: mock_utxo_ref(60 + variation),
    output: Output {
      address: mock_virtual_dex_address(),
      value: from_asset("", "", sell_lot_size),
      datum: InlineDatum(
        VirtualDexDatum {
          change_account_address: mock_change_account_address(),
          trade_account_address: mock_trade_account_address(),
          is_long: True,
          list_price_times_1mil,
          sell_lot_size,
        },
      ),
      reference_script: None,
    },
  }
}

pub fn mock_post_trade_trade_account_output(value: Value) -> Output {
  Output {
    address: mock_trade_account_address(),
    value,
    datum: InlineDatum(TradeNormalDatum),
    reference_script: None,
  }
}
