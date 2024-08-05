use aiken/bytearray
use aiken/list
use aiken/pairs
use aiken/transaction.{
  Input, Output, OutputReference, Redeemer, ScriptPurpose, Spend, find_input,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{
  AssetName, MintedValue, PolicyId, Value, flatten, from_minted_value, merge,
  quantity_of, zero,
}

pub fn check_policy_only_burn(mint: MintedValue, policy: PolicyId) -> Bool {
  let burn_value = flatten(from_minted_value(mint))
  list.all(
    burn_value,
    fn(x) {
      if x.1st == policy {
        x.3rd < 0
      } else {
        True
      }
    },
  )
}

pub fn convert_int_to_bytes(i: Int) -> ByteArray {
  convert_int_to_bytes_go(i, get_number_digit(i))
}

fn convert_int_to_bytes_go(newInt: Int, digit: Int) -> ByteArray {
  if digit == 1 {
    bytearray.push("", newInt + 48)
  } else {
    bytearray.push(
      convert_int_to_bytes_go(newInt % digit, digit / 10),
      newInt / digit + 48,
    )
  }
}

pub fn get_number_digit(i: Int) -> Int {
  go_get_number_digit(i, 1)
}

fn go_get_number_digit(newInt: Int, digit: Int) -> Int {
  if newInt < 10 {
    digit
  } else {
    go_get_number_digit(newInt / 10, digit * 10)
  }
}

pub fn value_length(value: Value) -> Int {
  list.length(flatten(value))
}

pub fn compare_output_reference(x, y) {
  expect Spend(out_ref_x) = x
  expect Spend(out_ref_y) = y
  bytearray.compare(
    out_ref_x.transaction_id.hash,
    out_ref_y.transaction_id.hash,
  )
}

pub fn inputs_token_quantity(
  inputs: List<Input>,
  token: (PolicyId, AssetName),
) -> Int {
  list.map(
    inputs,
    fn(input) { quantity_of(input.output.value, token.1st, token.2nd) },
  )
    |> list.foldr(0, fn(n, total) { n + total })
}

pub fn redeemer_from(
  redeemers: Pairs<ScriptPurpose, Redeemer>,
  inputs: List<Input>,
  output_reference: OutputReference,
  input_address: Address,
) -> Option<Data> {
  expect Some(redeemer) = pairs.get_first(redeemers, Spend(output_reference))
  expect Some(input) = find_input(inputs, output_reference)
  if input.output.address == input_address {
    Some(redeemer)
  } else {
    None
  }
}

pub fn get_all_value_to(outputs: List<Output>, address: Address) -> Value {
  list.foldr(
    outputs,
    zero(),
    fn(output, acc_value) {
      if output.address == address {
        merge(acc_value, output.value)
      } else {
        acc_value
      }
    },
  )
}

pub fn get_all_value_from(inputs: List<Input>, address: Address) -> Value {
  list.foldr(
    inputs,
    zero(),
    fn(input, acc_value) {
      if input.output.address == address {
        merge(acc_value, input.output.value)
      } else {
        acc_value
      }
    },
  )
}

test byte_conversion() {
  convert_int_to_bytes(1) == "1" && convert_int_to_bytes(123) == "123" && convert_int_to_bytes(
    672912,
  ) == "672912"
}
