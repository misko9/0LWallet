use std::os::raw::{c_char};
use std::ffi::{CString, CStr};
use std::str::FromStr;
use std::slice;
use anyhow::{Error, anyhow};
use diem_types::{
    account_state_blob::AccountStateBlob,
    account_state::AccountState,
};
use resource_viewer::{
    AnnotatedMoveValue,
    AnnotatedMoveStruct,
    AnnotatedAccountStateBlob,
    MoveValueAnnotator,
    NullStateView,
};
use move_core_types::{
    language_storage::TypeTag,
};
use bcs::from_bytes;
use ol_types::{
    makewhole_resource::{
        CreditResource,
        MakeWholeResource,
    },
    gas_resource::GasResource,
};

// TODO
// get vouching-for
// get auto-pay

// get burn to community
// validator ip / fullnode ip

#[no_mangle]
pub extern "C" fn rust_get_make_whole_credits_from_state(blob: *const c_char) ->  u64 {
    let account_state = get_account_state(blob);
    if let Ok(ac_st) = account_state {
        let mk = ac_st.get_resource::<MakeWholeResource>();
        if let Ok(Some(makewhole_resource)) = mk {
            let credits = makewhole_resource.credits;
            return credits[0].coins.value;
        }
    }
    /*let annotate_blob = get_annotated_account_state_blob(blob);
    if let Ok(ab) = annotate_blob {
        let credits = find_value_from_state(
            &ab,
            "MakeWhole".to_string(),
            "Balance".to_string(),
            "credits".to_string(),
        );
        if let Some(vec) = credits {
            //if let Some(AnnotatedMoveValue::Struct(vec)) = credits {
            let coin = find_value_in_struct(vec, "coins".to_string(),);
            if let Some(AnnotatedMoveValue::U64(amount)) = coin {
                return *amount;
            }
            return 78;
        }
        return 77;
    }*/
    0
}

#[no_mangle]
pub extern "C" fn rust_get_ancestry_from_state(blob: *const c_char) ->  *mut c_char {
    let mut ancestry: String = "None,".to_owned();
    let annotate_blob = get_annotated_account_state_blob(blob);
    if let Ok(ab) = annotate_blob {
        let ancestors = find_value_from_state(
            &ab,
            "Ancestry".to_string(),
            "Ancestry".to_string(),
            "tree".to_string(),
        );
        if let Some(AnnotatedMoveValue::Vector(TypeTag::Address, vec)) = ancestors {
            for v in vec {
                if let AnnotatedMoveValue::Address(addr) = v {
                    ancestry.push_str(&(String::from(addr) + ","));
                    //vouchers.push_str(format!("{},", &v));
                }
            }
        }
    }
    CString::new(&*ancestry).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn rust_get_vouchers_from_state(blob: *const c_char) ->  *mut c_char {
    let mut vouchers: String = "None,".to_owned();
    let annotate_blob = get_annotated_account_state_blob(blob);
    if let Ok(ab) = annotate_blob {
        let vouches = find_value_from_state(
            &ab,
            "Vouch".to_string(),
            "Vouch".to_string(),
            "vals".to_string(),
        );
        if let Some(AnnotatedMoveValue::Vector(TypeTag::Address, vec)) = vouches {
            for v in vec {
                if let AnnotatedMoveValue::Address(addr) = v {
                    vouchers.push_str(&(String::from(addr) + ","));
                    //vouchers.push_str(format!("{},", &v));
                }
            }
        }
    }
    CString::new(&*vouchers).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn rust_get_wallet_type_from_state(blob: *const c_char) ->  *mut c_char {
    let annotate_blob = get_annotated_account_state_blob(blob);
    if let Ok(ab) = annotate_blob {
        let community = find_value_from_state(
            &ab,
            "Wallet".to_string(),
            "CommunityFreeze".to_string(),
            "is_frozen".to_string(),
        );
        match community {
            Some(AnnotatedMoveValue::Bool(v)) => return CString::new("Community").unwrap().into_raw(),
            _ => ()
        }
        let unlocked = find_value_from_state(
            &ab,
            "DiemAccount".to_string(),
            "SlowWallet".to_string(),
            "unlocked".to_string(),
        );
        match unlocked {
            Some(AnnotatedMoveValue::U64(v)) => return CString::new("Slow").unwrap().into_raw(),
            _ => ()
        }
    }
    CString::new("Normal").unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn rust_get_unlocked_from_state(blob: *const c_char) -> u64 {
    let annotate_blob = get_annotated_account_state_blob(blob);
    if let Ok(ab) = annotate_blob {
        let unlocked = find_value_from_state(
            &ab,
            "DiemAccount".to_string(),
            "SlowWallet".to_string(),
            "unlocked".to_string(),
        );
        match unlocked {
            Some(AnnotatedMoveValue::U64(v)) => return *v,
            _ => ()
        }
    }
    0
}

#[no_mangle]
pub extern "C" fn rust_get_transferred_from_state(blob: *const c_char) -> u64 {
    let annotate_blob = get_annotated_account_state_blob(blob);
    if let Ok(ab) = annotate_blob {
        let unlocked = find_value_from_state(
            &ab,
            "DiemAccount".to_string(),
            "SlowWallet".to_string(),
            "transferred".to_string(),
        );
        match unlocked {
            Some(AnnotatedMoveValue::U64(v)) => return *v,
            _ => ()
        }
    }
    123
}

pub fn get_account_state(blob: *const c_char) -> Result<AccountState, &'static str> {
    let c_str = unsafe { CStr::from_ptr(blob) };
    let blob_str = match c_str.to_str() {
        Err(_) => "Error",
        Ok(string) => string,
    };

    let bcs_blob = bcs::from_bytes(&(hex::decode(blob_str).unwrap()));
    if let Ok(account_blob) = bcs_blob {
        let state_view = NullStateView::default();
        let annotator = MoveValueAnnotator::new(&state_view);
        let account_state = AccountState::try_from(&account_blob);
        if let Ok(ac_st) = account_state {
            return Ok(ac_st);
        }
    }
    Err("Failed to get Annoted Account State")
}

pub fn get_annotated_account_state_blob(blob: *const c_char) -> Result<AnnotatedAccountStateBlob, &'static str> {
    let c_str = unsafe { CStr::from_ptr(blob) };
    let blob_str = match c_str.to_str() {
        Err(_) => "Error",
        Ok(string) => string,
    };

    let bcs_blob = bcs::from_bytes(&(hex::decode(blob_str).unwrap()));
    if let Ok(account_blob) = bcs_blob {
        let state_view = NullStateView::default();
        let annotator = MoveValueAnnotator::new(&state_view);
        let account_state = AccountState::try_from(&account_blob);
        if let Ok(ac_st) = account_state {
            let annotate_blob =
                annotator.view_account_state(&ac_st);
            if let Ok(ab) = annotate_blob {
                return Ok(ab);
            }
        }
    }
    Err("Failed to get Annoted Account State")
}

/// find the value in a struct
pub fn find_value_in_struct(
    s: &AnnotatedMoveStruct,
    key_name: String,
) -> Option<&AnnotatedMoveValue> {
    match s
        .value
        .iter()
        .find(|v| v.0.clone().into_string() == key_name)
    {
        Some((_, v)) => Some(v),
        None => None,
    }
}

/// finds a value
pub fn find_value_from_state(
    blob: &AnnotatedAccountStateBlob,
    module_name: String,
    struct_name: String,
    key_name: String,
) -> Option<&AnnotatedMoveValue> {
    match blob.0.values().find(|&s| {
        s.type_.module.as_ref().to_string() == module_name
            && s.type_.name.as_ref().to_string() == struct_name
    }) {
        Some(s) => find_value_in_struct(s, key_name),
        None => None,
    }
}