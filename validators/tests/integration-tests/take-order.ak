use aiken/dict.{Dict}
use aiken/list
use aiken/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, Redeemer, ScriptContext,
  ScriptPurpose, Spend, Transaction, TransactionId, placeholder,
}
use aiken/transaction/credential.{
  Address, Inline, ScriptCredential, VerificationKeyCredential,
}
use aiken/transaction/value.{add, from_asset}
use aiken_virtual_dex/common.{compare_output_reference}
use aiken_virtual_dex/placeholder.{ada_asset_class, mock_emergency_token}
use aiken_virtual_dex/types.{
  OracleDatum, TakeOrder, TradeNormalAction, TradeNormalDatum, VirtualDexDatum,
}
use aiken_virtual_dex/validators/virtual_dex.{virtual_dex_logic}

pub fn script_address(script_hash: ByteArray) -> Address {
  Address {
    payment_credential: ScriptCredential(script_hash),
    stake_credential: Some(
      Inline(
        VerificationKeyCredential(
          #"5ca749261aa3b17aa2cd4b026bc6566c4b14421d6083edce64ffe5cb",
        ),
      ),
    ),
  }
}

pub fn pubkey_address(payment_hash: ByteArray) -> Address {
  Address {
    payment_credential: VerificationKeyCredential(payment_hash),
    stake_credential: Some(
      Inline(
        VerificationKeyCredential(
          #"5ca749261aa3b17aa2cd4b026bc6566c4b14421d6083edce64ffe5cb",
        ),
      ),
    ),
  }
}

pub fn utxo_ref(tx_hash: ByteArray, output_index: Int) -> OutputReference {
  OutputReference { transaction_id: TransactionId(tx_hash), output_index }
}

fn take_order_test() -> Transaction {
  let inputs =
    [
      Input {
        output_reference: utxo_ref(
          #"333d35345958010502188e210635fe1e7c6818124258a4e263befdb9d960013b",
          2,
        ),
        output: Output {
          address: script_address(
            #"b8448a2aa1138dddb668dc862623b1155b39c3b708c2b598130a3073",
          ),
          value: from_asset("", "", 500000000),
          datum: InlineDatum(TradeNormalDatum),
          reference_script: None,
        },
      },
      Input {
        output_reference: utxo_ref(
          #"333d35345958010502188e210635fe1e7c6818124258a4e263befdb9d960013b",
          3,
        ),
        output: Output {
          address: script_address(
            #"b8448a2aa1138dddb668dc862623b1155b39c3b708c2b598130a3073",
          ),
          value: from_asset("", "", 1500000)
            |> add(
                 #"5066154a102ee037390c5236f78db23239b49c5748d3d349f3ccf04b",
                 #"55534458",
                 250000000,
               ),
          datum: InlineDatum(TradeNormalDatum),
          reference_script: None,
        },
      },
      Input {
        output_reference: utxo_ref(
          #"333d35345958010502188e210635fe1e7c6818124258a4e263befdb9d960013b",
          4,
        ),
        output: Output {
          address: script_address(
            #"b8448a2aa1138dddb668dc862623b1155b39c3b708c2b598130a3073",
          ),
          value: from_asset("", "", 1500000)
            |> add(
                 #"5066154a102ee037390c5236f78db23239b49c5748d3d349f3ccf04b",
                 #"55534458",
                 50000000,
               ),
          datum: InlineDatum(TradeNormalDatum),
          reference_script: None,
        },
      },
      Input {
        output_reference: utxo_ref(
          #"da54b203b14cd36ede2e95f172db58eee5e0a86170a8f757c862ffc208d8679c",
          0,
        ),
        output: Output {
          address: script_address(
            #"6bbb89ee610e7866d325d3bd5b55a984183ad0962fe6e1be4aec378f",
          ),
          value: from_asset("", "", 504316071),
          datum: InlineDatum(
            VirtualDexDatum {
              change_account_address: script_address(
                #"ccf8e7e341a62a8ffd345d1705b9103a661fd8faa403b33080fac35c",
              ),
              trade_account_address: script_address(
                #"d5f9fc2c6b5300b516ab106797632baeab6047843c06b5706e04e16f",
              ),
              is_long: False,
              list_price_times_1mil: 574000,
              lot_size: 500000000,
            },
          ),
          reference_script: None,
        },
      },
    ]
  let outputs =
    [
      Output {
        address: script_address(
          #"ccf8e7e341a62a8ffd345d1705b9103a661fd8faa403b33080fac35c",
        ),
        value: from_asset("", "", 1500000)
          |> add(
               #"5066154a102ee037390c5236f78db23239b49c5748d3d349f3ccf04b",
               #"55534458",
               250000000,
             ),
        datum: InlineDatum(TradeNormalDatum),
        reference_script: None,
      },
      Output {
        address: script_address(
          #"d5f9fc2c6b5300b516ab106797632baeab6047843c06b5706e04e16f",
        ),
        value: from_asset("", "", 2066071)
          |> add(
               #"5066154a102ee037390c5236f78db23239b49c5748d3d349f3ccf04b",
               #"55534458",
               37000000,
             ),
        datum: InlineDatum(TradeNormalDatum),
        reference_script: None,
      },
      Output {
        address: script_address(
          #"57f7ddf8c822daad03fd80823153a61d913e5c9147bd478e3ccd70b3",
        ),
        value: from_asset("", "", 500000000),
        datum: InlineDatum(TradeNormalDatum),
        reference_script: None,
      },
      Output {
        address: script_address(
          #"57f7ddf8c822daad03fd80823153a61d913e5c9147bd478e3ccd70b3",
        ),
        value: from_asset("", "", 5750000),
        datum: InlineDatum(TradeNormalDatum),
        reference_script: None,
      },
      Output {
        address: script_address(
          #"57f7ddf8c822daad03fd80823153a61d913e5c9147bd478e3ccd70b3",
        ),
        value: from_asset("", "", 5750000),
        datum: InlineDatum(TradeNormalDatum),
        reference_script: None,
      },
      Output {
        address: pubkey_address(
          #"5ca51b304b1f79d92eada8c58c513e969458dcd27ce4f5bc47823ffa",
        ),
        value: from_asset("", "", 1121800),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  let extra_signatories =
    [
      #"d161d64eef0eeb59f9124f520f8c8f3b717ed04198d54c8b17e604ae",
      #"5ca51b304b1f79d92eada8c58c513e969458dcd27ce4f5bc47823ffa",
    ]

  let reference_inputs =
    [
      Input {
        output_reference: utxo_ref(
          #"efe6fbbdd6b993d96883b96c572bfcaa0a4a138c83bd948dec1751d1bfda09b3",
          0,
        ),
        output: Output {
          address: script_address(
            #"25b86eea84a44a3cf98bf470e2dafa02a8d95b81028c51583610297e",
          ),
          value: from_asset(
            #"e6e5285a878161c101a59b4e36f1f99e5e464d30f510be3ee34f907f",
            "",
            1,
          )
            |> add(#"", #"", 1909330),
          datum: InlineDatum(
            OracleDatum {
              oracle_nft: #"e6e5285a878161c101a59b4e36f1f99e5e464d30f510be3ee34f907f",
              oracle_address: script_address(
                #"25b86eea84a44a3cf98bf470e2dafa02a8d95b81028c51583610297e",
              ),
              operation_key: #"5ca51b304b1f79d92eada8c58c513e969458dcd27ce4f5bc47823ffa",
              stop_key: #"bbb1a36cc3e076d689176e77374ca26d4e09047c9d9dbd10ab0dcdae",
            },
          ),
          reference_script: None,
        },
      },
    ]
      |> list.concat(inputs)

  let redeemer1: Redeemer = TradeNormalAction
  let redeemer2: Redeemer = TakeOrder

  let redeemers: Dict<ScriptPurpose, Redeemer> =
    dict.from_list(
      [
        (
          Spend(
            utxo_ref(
              #"333d35345958010502188e210635fe1e7c6818124258a4e263befdb9d960013b",
              2,
            ),
          ),
          redeemer1,
        ),
        (
          Spend(
            utxo_ref(
              #"333d35345958010502188e210635fe1e7c6818124258a4e263befdb9d960013b",
              3,
            ),
          ),
          redeemer1,
        ),
        (
          Spend(
            utxo_ref(
              #"333d35345958010502188e210635fe1e7c6818124258a4e263befdb9d960013b",
              4,
            ),
          ),
          redeemer1,
        ),
        (
          Spend(
            utxo_ref(
              #"da54b203b14cd36ede2e95f172db58eee5e0a86170a8f757c862ffc208d8679c",
              0,
            ),
          ),
          redeemer2,
        ),
      ],
      compare_output_reference,
    )

  Transaction {
    ..placeholder(),
    reference_inputs: reference_inputs,
    inputs: inputs,
    extra_signatories: extra_signatories,
    outputs: outputs,
    fee: from_asset("", "", 378200),
    redeemers: redeemers,
  }
}

test preprod_fill_order_test() {
  let dat =
    VirtualDexDatum {
      change_account_address: script_address(
        #"ccf8e7e341a62a8ffd345d1705b9103a661fd8faa403b33080fac35c",
      ),
      trade_account_address: script_address(
        #"d5f9fc2c6b5300b516ab106797632baeab6047843c06b5706e04e16f",
      ),
      is_long: False,
      list_price_times_1mil: 574000,
      lot_size: 500000000,
    }
  let red = TakeOrder
  let tx = take_order_test()
  let ctx =
    ScriptContext {
      purpose: Spend(
        utxo_ref(
          #"da54b203b14cd36ede2e95f172db58eee5e0a86170a8f757c862ffc208d8679c",
          0,
        ),
      ),
      transaction: tx,
    }
  virtual_dex_logic(
    #"e6e5285a878161c101a59b4e36f1f99e5e464d30f510be3ee34f907f",
    mock_emergency_token(),
    ada_asset_class(),
    (#"5066154a102ee037390c5236f78db23239b49c5748d3d349f3ccf04b", #"55534458"),
    dat,
    red,
    ctx,
  )
}
// test asset_class_test() {
//   let asset_unit = #"5066154a102ee037390c5236f78db23239b49c5748d3d349f3ccf04b"
//   let asset_name = #"55534458"
//   let asset_class = (asset_unit, asset_name)
//   cbor.diagnostic(asset_class) == @""
// }
