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
use byteorder::{LittleEndian, WriteBytesExt};
use ol_keys::wallet;
//use hex;

const VDF_SECURITY_PARAM: u16 = 512;
const VDF_DIFFICULTY_PARAM: u64 = 120_000_000;

#[no_mangle]
pub extern "C" fn rust_solve_proof(
    last_hash: *const c_char,
    mnem: *const c_char,
    sequence_num: u64,
    height: u64,
) ->  *mut c_char {
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
    let vdf: vdf::PietrzakVDF = PietrzakVDFParams(VDF_SECURITY_PARAM).new();
    let now = Instant::now();
    if let Ok(proof) = vdf.solve(&preimage, VDF_DIFFICULTY_PARAM) {
        let elapsed_secs = now.elapsed().as_secs();
        //match vdf.verify(&preimage, VDF_DIFFICULTY_PARAM, &proof) {
        //    Ok(_) => {
                let block = VDFProof {
                    height: height,
                    elapsed_secs: elapsed_secs,
                    preimage: preimage,
                    proof: proof.clone(),
                    difficulty: Some(VDF_DIFFICULTY_PARAM),
                    security: Some(VDF_SECURITY_PARAM),
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

#[no_mangle]
pub extern "C" fn rust_solve_genesis_proof(
    mnem: *const c_char,
    sequence_num: u64,
) ->  *mut c_char {
    let c_str2 = unsafe { CStr::from_ptr(mnem)};
    let mnem_str = match c_str2.to_str() {
        Err(_) => "Error",
        Ok(string) => string,
    };

    let preimage = genesis_preimage(mnem_str.clone().parse().unwrap());

    //return CString::new(hex::encode(preimage)).unwrap().into_raw();

    // Functions for running the VDF.
    let vdf: vdf::PietrzakVDF = PietrzakVDFParams(VDF_SECURITY_PARAM).new();
    let now = Instant::now();
    if let Ok(proof) = vdf.solve(&preimage, VDF_DIFFICULTY_PARAM) {
        let elapsed_secs = now.elapsed().as_secs();
        //match vdf.verify(&preimage, VDF_DIFFICULTY_PARAM, &proof) {
        //    Ok(_) => {
        let block = VDFProof {
            height: 0,
            elapsed_secs: elapsed_secs,
            preimage: preimage,
            proof: proof.clone(),
            difficulty: Some(VDF_DIFFICULTY_PARAM),
            security: Some(VDF_SECURITY_PARAM),
        };
        //return CString::new(serde_json::to_string(&block).unwrap()).unwrap().into_raw();
        let tx_params = get_custom_tx_params(mnem_str.clone().parse().unwrap()).unwrap();
        match sign_proof(block, tx_params, sequence_num) {
            Ok(r) => {
                let encodedPayload = hex::encode(bcs::to_bytes(&r).unwrap());
                return CString::new(encodedPayload).unwrap().into_raw();
            },
            Err(_) => {
                return CString::new("Failed signing genesis proof").unwrap().into_raw();
            },
        }
        //},
        //Err(e) => return CString::new("Failed, proof is not valid.").unwrap().into_raw()
        //}
    }
    CString::new("Failed making genesis proof").unwrap().into_raw()
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

/// Format the config file data into a fixed byte structure for easy parsing in Move/other languages
pub fn genesis_preimage(mnem: String) -> Vec<u8> {
    const AUTH_KEY_BYTES: usize = 32;
    const CHAIN_ID_BYTES: usize = 16;
    const DIFFICULTY_BYTES: usize = 8;
    const SECURITY_BYTES: usize = 8;
    const PIETRZAK: usize = 1; // PIETRZAK = 1, WESOLOWSKI = 2
    const LINK_TO_TOWER: usize = 64; // optional, hash of the last proof of an existing tower.
    const STATEMENT_BYTES: usize = 895; // remainder

    let mut preimage: Vec<u8> = vec![];

    // AUTH_KEY_BYTES
    let (auth_key, _, _) = wallet::get_account_from_mnem(mnem).unwrap();
    let mut padded_key_bytes = padding(auth_key.to_vec(), AUTH_KEY_BYTES);

    preimage.append(&mut padded_key_bytes);

    // * CHAIN_ID_BYTES
    let mut padded_chain_id_bytes = padding("Mainnet".to_string().as_bytes().to_vec(), CHAIN_ID_BYTES);

    preimage.append(&mut padded_chain_id_bytes);

    // * DIFFICULTY_BYTES
    preimage
        .write_u64::<LittleEndian>(VDF_DIFFICULTY_PARAM)
        .unwrap();

    // * SECURITY_BYTES
    preimage
        .write_u64::<LittleEndian>(VDF_SECURITY_PARAM.into())
        .unwrap();

    // * PIETRZAK
    preimage
        .write_u8(1)
        .unwrap();

    // * LINK_TO_TOWER
    let mut padded_tower_link_bytes = padding("".to_string().into_bytes(), LINK_TO_TOWER);
    preimage.append(&mut padded_tower_link_bytes);

    // * STATEMENT
    let mut padded_statements_bytes = padding("Proof Ripper".to_string().as_bytes().to_vec(), STATEMENT_BYTES);
    preimage.append(&mut padded_statements_bytes);

    assert_eq!(
        preimage.len(),
        (
            AUTH_KEY_BYTES // 0L Auth_Key
                + CHAIN_ID_BYTES // chain_id
                + DIFFICULTY_BYTES // iterations/difficulty
                + SECURITY_BYTES
                + PIETRZAK
                + LINK_TO_TOWER
                + STATEMENT_BYTES
            // = 1024
        ),
        "Preimage is the incorrect byte length"
    );

    assert_eq!(
        preimage.len(),
        1024,
        "Preimage is the incorrect byte length"
    );

    return preimage;
}

fn padding(mut statement_bytes: Vec<u8>, limit: usize) -> Vec<u8> {
    match statement_bytes.len() {
        d if d > limit => panic!(
            "Message is longer than {} bytes. Got {} bytes",
            limit,
            statement_bytes.len()
        ),
        d if d < limit => {
            let padding_length = limit - statement_bytes.len() as usize;
            let mut padding_bytes: Vec<u8> = vec![0; padding_length];
            padding_bytes.append(&mut statement_bytes);
            padding_bytes
        }
        d if d == limit => statement_bytes,
        _ => unreachable!(),
    }
}