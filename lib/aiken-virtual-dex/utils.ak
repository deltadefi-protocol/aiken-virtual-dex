use aiken_virtual_dex/common.{convert_int_to_bytes}

pub fn get_account_token_name(count: Int) -> ByteArray {
  convert_int_to_bytes(count)
}
