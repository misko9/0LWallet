use crate::balance_transfer::{sign_tx, get_custom_tx_params, TxParams};
use std::os::raw::{c_char};
use std::ffi::{CString, CStr};
use anyhow::{Error, anyhow};
use vdf::{PietrzakVDFParams, VDF, VDFParams};
use ol_types::block::VDFProof;
use diem_types::{
    chain_id::ChainId,
    waypoint::Waypoint,
    transaction::{SignedTransaction, helpers::create_user_txn},
};
use diem_transaction_builder::stdlib as transaction_builder;
use std::time::Instant;
//use hex;

#[no_mangle]
pub extern "C" fn rust_solve_proof(
    last_hash: *const c_char,
    mnem: *const c_char,
    sequence_num: u64,
    height: u64,
) ->  *mut c_char {
    //  let difficulty: u64 = 1200000;
    let difficulty: u64 = 120000000;
    let security: u16 = 512;

    let c_str = unsafe { CStr::from_ptr(last_hash) };
    let hash_str = match c_str.to_str() {
        Err(_) => "Error",
        Ok(string) => string,
    };

    let c_str2 = unsafe { CStr::from_ptr(mnem)};
    let mnem_str = match c_str2.to_str() {
        Err(_) => "Error",
        Ok(string) => string,
    };

    let preimage = hex::decode(hash_str).unwrap();

    // Functions for running the VDF.
    let vdf: vdf::PietrzakVDF = PietrzakVDFParams(security).new();
    let now = Instant::now();
    if let Ok(proof) = vdf.solve(&preimage, difficulty) {
        let elapsed_secs = now.elapsed().as_secs();
        //match vdf.verify(&preimage, difficulty, &proof) {
        //    Ok(_) => {
                let block = VDFProof {
                    height: height,
                    elapsed_secs: elapsed_secs,
                    preimage: preimage,
                    proof: proof.clone(),
                    difficulty: Some(difficulty),
                    security: Some(security),
                };
                //return CString::new(serde_json::to_string(&block).unwrap()).unwrap().into_raw();
                let tx_params = get_custom_tx_params(mnem_str.clone().parse().unwrap()).unwrap();
                match sign_proof(block, tx_params, sequence_num) {
                    Ok(r) => {
                        let encodedPayload = hex::encode(bcs::to_bytes(&r).unwrap());
                        return CString::new(encodedPayload).unwrap().into_raw();
                    },
                    Err(_) => {
                        return CString::new("Failed signing proof").unwrap().into_raw();
                    },
                }
            //},
            //Err(e) => return CString::new("Failed, proof is not valid.").unwrap().into_raw()
        //}
    }
    CString::new("Failed making proof").unwrap().into_raw()
}

pub fn sign_proof(block: VDFProof, tx_params: TxParams, sequence_number: u64)
                               -> Result<SignedTransaction, Error> {
    let script = transaction_builder::encode_minerstate_commit_script_function(
        block.preimage.clone(),
        block.proof.clone(),
        block.difficulty(),
        block.security(),
    );
    sign_tx(
        script,
        &tx_params,
        sequence_number,
        ChainId::new(1))
}