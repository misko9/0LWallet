use std::os::raw::{c_char};
use std::ffi::{CString, CStr};
//use std::{thread, time, io::{stdout, Write}};
use std::str::FromStr;
use url::{Url, ParseError};
use anyhow::{Error, anyhow};
//use cli::{diem_client::DiemClient, AccountData, AccountStatus};
//use cli::{diem_client::{DiemClient, views::VMStatusView}, AccountData, AccountStatus};
use diem_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    test_utils::KeyPair,
};
use diem_transaction_builder::stdlib as transaction_builder;
use diem_json_rpc_types::views::TransactionView;
use diem_types::{
    chain_id::ChainId,
    account_address::AccountAddress,
    waypoint::Waypoint,
    transaction::{authenticator::AuthenticationKey, SignedTransaction, TransactionPayload, helpers::create_user_txn},
};
use diem_wallet::{WalletLibrary, Mnemonic};
use ol_keys::{scheme::KeyScheme, wallet};
use ol_types::config::{TxCost, TxType};
use serde::Serialize;

const PROLOGUE_EACCOUNT_DNE: u64 = 1004;

#[no_mangle]
pub extern "C" fn rust_balance_transfer(coins: u64, sequence_num: u64, dest_addr: *const c_char, mnem: *const c_char) -> *mut c_char  {
    let c_str = unsafe { CStr::from_ptr(mnem)};
    let mnem_str = match c_str.to_str() {
        Err(_) => "Error",
        Ok(string) => string,
    };
    let tx_params = get_custom_tx_params(mnem_str.clone().parse().unwrap()).unwrap();

    let c_str2 = unsafe { CStr::from_ptr(dest_addr)};
    let dest_addr_str = match c_str2.to_str() {
        Err(_) => "Error",
        Ok(string) => string,
    };
    let address = "0x".to_owned() + dest_addr_str;
    if let Ok(account_address) = AccountAddress::from_hex_literal(&*address) {
        match custom_balance_transfer(account_address, coins, tx_params, sequence_num) {
            Ok(r) => {
                let encodedPayload = hex::encode(bcs::to_bytes(&r).unwrap());
                CString::new(encodedPayload).unwrap().into_raw()
            },
            Err(_) => {
                CString::new("Err1").unwrap().into_raw()
            },
        }
    } else {
        CString::new("Err2").unwrap().into_raw()
    }
}

pub fn custom_balance_transfer(destination: AccountAddress, coins: u64, tx_params: TxParams, sequence_number: u64)
    -> Result<SignedTransaction, Error> {
    // NOTE: coins here do not have the scaling factor. Rescaling is the responsibility of the Move script. See the script in ol_accounts.move for detail.
    let script = transaction_builder::encode_balance_transfer_script_function(
        destination,
        coins,
    );

    sign_tx(
        script,
        &tx_params,
        sequence_number,
        ChainId::new(1)
    )
}

/// sign a raw transaction script, and return a SignedTransaction
pub fn sign_tx(
    script: TransactionPayload,
    tx_params: &TxParams,
    sequence_number: u64,
    chain_id: ChainId,
) -> Result<SignedTransaction, Error> {
    // sign the transaction script
    create_user_txn(
        &tx_params.keypair,
        script,
        tx_params.signer_address,
        sequence_number,
        tx_params.tx_cost.max_gas_unit_for_tx,
        tx_params.tx_cost.coin_price_per_unit,
        "GAS".parse().unwrap(),
        tx_params.tx_cost.user_tx_timeout as i64, // for compatibility with UTC's timestamp.
        chain_id,
    )
}

/// tx_parameters format
pub fn get_custom_tx_params(mnem: String) -> Result<TxParams, Error> {
    //TODO Pass in URL
    let url = Url::parse("http://135.181.118.28:8080").unwrap();
    const BASE_WAYPOINT: &str = "29991903:6a350be0f85eecbe159c4948b9f4e393b7081c9c1ae9d6f70b15fac3b20740f2";
    // TODO Should I get a new waypoint?
    let waypoint = Waypoint::from_str(BASE_WAYPOINT).unwrap();

    let (auth_key, address, wallet) = wallet::get_account_from_mnem(mnem).unwrap();
    let keys = KeyScheme::new_from_mnemonic(wallet.mnemonic());
    let keypair = KeyPair::from(keys.child_0_owner.get_private_key());

    // TODO Pass in costs
    let tx_cost = TxCost::new(10_000);

    // main net id
    let chain_id = ChainId::new(1);

    let tx_params = TxParams {
        auth_key,
        signer_address: address,
        owner_address: address,
        url,
        waypoint,
        keypair,
        tx_cost: tx_cost.to_owned(),
        // max_gas_unit_for_tx: config.tx_configs.management_txs.max_gas_unit_for_tx,
        // coin_price_per_unit: config.tx_configs.management_txs.coin_price_per_unit, // in micro_gas
        // user_tx_timeout: config.tx_configs.management_txs.user_tx_timeout,
        chain_id,
    };

    Ok(tx_params)
}

/// All the parameters needed for a client transaction.
#[derive(Debug)]
pub struct TxParams {
    /// User's 0L authkey used in mining.
    pub auth_key: AuthenticationKey,
    /// Address of the signer of transaction, e.g. owner's operator
    pub signer_address: AccountAddress,
    /// Optional field for Miner, for operator to send owner
    // TODO: refactor so that this is not par of the TxParams type
    pub owner_address: AccountAddress,
    /// Url
    pub url: Url,
    /// waypoint
    pub waypoint: Waypoint,
    /// KeyPair
    pub keypair: KeyPair<Ed25519PrivateKey, Ed25519PublicKey>,
    /// tx cost and timeout info
    pub tx_cost: TxCost,
    // /// User's Maximum gas_units willing to run. Different than coin.
    // pub max_gas_unit_for_tx: u64,
    // /// User's GAS Coin price to submit transaction.
    // pub coin_price_per_unit: u64,
    // /// User's transaction timeout.
    // pub user_tx_timeout: u64, // for compatibility with UTC's timestamp.
    /// Chain id
    pub chain_id: ChainId,
}