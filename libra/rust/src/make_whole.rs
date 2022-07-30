use crate::balance_transfer::{sign_tx, get_custom_tx_params, TxParams};
use std::os::raw::{c_char};
use std::ffi::{CString, CStr};
use diem_types::{
    chain_id::ChainId,
//    transaction::{SignedTransaction, helpers::create_user_txn},
};
use diem_transaction_builder::stdlib as transaction_builder;

#[no_mangle]
pub extern "C" fn rust_claim_make_whole(sequence_num: u64, mnem: *const c_char) -> *mut c_char {
    let c_str = unsafe { CStr::from_ptr(mnem) };
    let mnem_str = match c_str.to_str() {
        Err(_) => "Error",
        Ok(string) => string,
    };
    let tx_params = get_custom_tx_params(mnem_str.clone().parse().unwrap()).unwrap();

    let script = transaction_builder::encode_claim_make_whole_script_function();
    match sign_tx(script, &tx_params, sequence_num, ChainId::new(1)) {
        Ok(r) => {
            let encodedPayload = hex::encode(bcs::to_bytes(&r).unwrap());
            return CString::new(encodedPayload).unwrap().into_raw();
        }
        Err(_) => {
            return CString::new("Err1").unwrap().into_raw();
        }
    }
    CString::new("Err2").unwrap().into_raw()
}
