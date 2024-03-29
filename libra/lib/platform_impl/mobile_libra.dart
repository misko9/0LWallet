import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';

import 'package:flutter/services.dart';

import 'base_libra.dart';

DynamicLibrary libraNative({String basePath = ''}) {
  if (Platform.isAndroid || Platform.isLinux) {
    //return DynamicLibrary.process();
    //return DynamicLibrary.executable();
    return DynamicLibrary.open('${basePath}liblibra.so');
  } else if (Platform.isIOS) {
    // iOS is statically linked, so it is the same as the current process
    return DynamicLibrary.process();
  } else if (Platform.isMacOS) {
    return DynamicLibrary.open('${basePath}liblibra.dylib');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('${basePath}liblibra.dll');
  } else {
    throw NotSupportedPlatform('${Platform.operatingSystem} is not supported!');
  }
}

class NotSupportedPlatform implements Exception {
  NotSupportedPlatform(String s);
}

// For C/Rust
//typedef rust_add_func = Int64 Function(Int64 a, Int64 b);
//typedef rust_greeting_func = Pointer<Utf8> Function(Pointer<Utf8>);
typedef rust_get_address_from_mnem_func = Pointer<Utf8> Function(Pointer<Utf8>);
typedef rust_is_mnem_valid_func = Bool Function(Pointer<Utf8>);
typedef rust_balance_transfer_func = Pointer<Utf8> Function(Int64 coins, Int64 sequence_num, Pointer<Utf8> dest_addr, Pointer<Utf8> mnem);
typedef rust_community_balance_transfer_func = Pointer<Utf8> Function(Int64 coins, Int64 sequence_num, Pointer<Utf8> dest_addr, Pointer<Utf8> mnem);
typedef rust_cstr_free = Void Function(Pointer<Utf8> s);
typedef rust_get_unlocked_from_state_func = Int64 Function(Pointer<Utf8>);
typedef rust_get_transferred_from_state_func = Int64 Function(Pointer<Utf8>);
typedef rust_get_wallet_type_from_state_func = Pointer<Utf8> Function(Pointer<Utf8>);
typedef rust_get_vouchers_from_state_func = Pointer<Utf8> Function(Pointer<Utf8>);
typedef rust_get_ancestry_from_state_func = Pointer<Utf8> Function(Pointer<Utf8>);
typedef rust_get_make_whole_credits_from_state_func = Int64 Function(Pointer<Utf8>);
typedef rust_is_make_whole_claimed_from_state_func = Bool Function(Pointer<Utf8>);
typedef rust_is_validator_from_state_func = Bool Function(Pointer<Utf8>);
typedef rust_is_operator_from_state_func = Bool Function(Pointer<Utf8>);
typedef rust_claim_make_whole_func = Pointer<Utf8> Function(Int64 sequence_num, Pointer<Utf8> mnem);
// For Dart
//typedef DartAdd = int Function(int a, int b);
//typedef DartGreeting = Pointer<Utf8> Function(Pointer<Utf8>);
typedef DartGetAddrFromMnem = Pointer<Utf8> Function(Pointer<Utf8>);
typedef DartIsMnemValid = bool Function(Pointer<Utf8>);
typedef DartBalanceTransfer = Pointer<Utf8> Function(int coins, int sequence_num, Pointer<Utf8> dest_addr, Pointer<Utf8> mnem);
typedef DartCommunityBalanceTransfer = Pointer<Utf8> Function(int coins, int sequence_num, Pointer<Utf8> dest_addr, Pointer<Utf8> mnem);
typedef DartCstrFree = void Function(Pointer<Utf8> s);
typedef DartGetUnlockedFromState = int Function(Pointer<Utf8>);
typedef DartGetTransferredFromState = int Function(Pointer<Utf8>);
typedef DartGetWalletTypeFromState = Pointer<Utf8> Function(Pointer<Utf8>);
typedef DartGetVouchersFromState = Pointer<Utf8> Function(Pointer<Utf8>);
typedef DartGetAncestryFromState = Pointer<Utf8> Function(Pointer<Utf8>);
typedef DartGetMakeWholeCreditsFromState = int Function(Pointer<Utf8>);
typedef DartIsMakeWholeClaimedFromState = bool Function(Pointer<Utf8>);
typedef DartIsValidatorFromState = bool Function(Pointer<Utf8>);
typedef DartIsOperatorFromState = bool Function(Pointer<Utf8>);
typedef DartClaimMakeWhole = Pointer<Utf8> Function(int sequence_num, Pointer<Utf8> mnem);

class LibraImpl extends BaseLibra {
  static const MethodChannel _channel = MethodChannel('libra');
  static DynamicLibrary? _lib;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  LibraImpl() {
    if (_lib != null) return;
    // for debugging and tests
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _lib = libraNative();
      //_lib = libraNative(basePath: '../../../target/debug/');
    } else {
      _lib = libraNative();
    }
  }

  /*int adder(int a, int b) {
    // get a function pointer to the symbol called `add`
    final addPointer = _lib!.lookup<NativeFunction<rust_add_func>>('rust_add');
    // and use it as a function
    final sum = addPointer.asFunction<DartAdd>();
    return sum(a, b);
  }*/

  /*String greeting(String name) {
    final greetingPointer = _lib!.lookup<NativeFunction<rust_greeting_func>>('rust_greeting');
    final greeting = greetingPointer.asFunction<DartGreeting>();
    return greeting(name.toNativeUtf8()).toDartString();
  }*/

  @override
  String get_address_from_mnem(String mnem) {
    final walletPointer = _lib!.lookup<NativeFunction<rust_get_address_from_mnem_func>>('get_addr_from_mnem');
    final getAddr = walletPointer.asFunction<DartGetAddrFromMnem>();
    Pointer<Utf8> addr = getAddr(mnem.toNativeUtf8());
    String finalAddrStr = addr != null ? ""+addr.toDartString() : "null";
    _rust_cstr_free(addr);
    return finalAddrStr;
  }

  @override
  bool is_mnem_valid(String mnem) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_is_mnem_valid_func>>('is_mnem_valid');
    final myFunction = fnPointer.asFunction<DartIsMnemValid>();
    return myFunction(mnem.toNativeUtf8());
  }

  @override
  String balance_transfer(String dest_addr, int coins, String mnem, int sequence_num) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_balance_transfer_func>>('rust_balance_transfer');
    var myFunction = fnPointer.asFunction<DartBalanceTransfer>();
    Pointer<Utf8> signedTx = myFunction(coins, sequence_num, dest_addr.toNativeUtf8(), mnem.toNativeUtf8());
    String finalSignedTx = signedTx != null ? ""+signedTx.toDartString() : "null";
    _rust_cstr_free(signedTx);
    return finalSignedTx;
  }

  @override
  String community_balance_transfer(String dest_addr, int coins, String mnem, int sequence_num) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_community_balance_transfer_func>>('rust_community_balance_transfer');
    var myFunction = fnPointer.asFunction<DartCommunityBalanceTransfer>();
    Pointer<Utf8> signedTx = myFunction(coins, sequence_num, dest_addr.toNativeUtf8(), mnem.toNativeUtf8());
    String finalSignedTx = signedTx != null ? ""+signedTx.toDartString() : "null";
    _rust_cstr_free(signedTx);
    return finalSignedTx;
  }

  void _rust_cstr_free(Pointer<Utf8> s) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_cstr_free>>('rust_cstr_free');
    final myFunction = fnPointer.asFunction<DartCstrFree>();
    return myFunction(s);
  }

  @override
  int get_unlocked_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_get_unlocked_from_state_func>>('rust_get_unlocked_from_state');
    final myFunction = fnPointer.asFunction<DartGetUnlockedFromState>();
    return myFunction(blob.toNativeUtf8());
  }

  @override
  int get_transferred_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_get_transferred_from_state_func>>('rust_get_transferred_from_state');
    final myFunction = fnPointer.asFunction<DartGetTransferredFromState>();
    return myFunction(blob.toNativeUtf8());
  }

  @override
  String get_wallet_type_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_get_wallet_type_from_state_func>>('rust_get_wallet_type_from_state');
    final myFunction = fnPointer.asFunction<DartGetWalletTypeFromState>();
    Pointer<Utf8> walletType = myFunction(blob.toNativeUtf8());
    String walletTypeStr = walletType != null ? ""+walletType.toDartString() : "";
    _rust_cstr_free(walletType);
    return walletTypeStr;
  }

  @override
  String get_vouchers_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_get_vouchers_from_state_func>>('rust_get_vouchers_from_state');
    final myFunction = fnPointer.asFunction<DartGetVouchersFromState>();
    Pointer<Utf8> vouchers = myFunction(blob.toNativeUtf8());
    String vouchersStr = vouchers != null ? ""+vouchers.toDartString() : "";
    _rust_cstr_free(vouchers);
    return vouchersStr;
  }

  @override
  String get_ancestry_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_get_ancestry_from_state_func>>('rust_get_ancestry_from_state');
    final myFunction = fnPointer.asFunction<DartGetAncestryFromState>();
    Pointer<Utf8> ancestry = myFunction(blob.toNativeUtf8());
    String ancestryStr = ancestry != null ? ""+ancestry.toDartString() : "";
    _rust_cstr_free(ancestry);
    return ancestryStr;
  }

  @override
  int get_make_whole_credits_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_get_make_whole_credits_from_state_func>>('rust_get_make_whole_credits_from_state');
    final myFunction = fnPointer.asFunction<DartGetMakeWholeCreditsFromState>();
    return myFunction(blob.toNativeUtf8());
  }

  @override
  bool is_make_whole_claimed_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_is_make_whole_claimed_from_state_func>>('rust_is_make_whole_claimed_from_state');
    final myFunction = fnPointer.asFunction<DartIsMakeWholeClaimedFromState>();
    return myFunction(blob.toNativeUtf8());
  }

  @override
  bool is_validator_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_is_validator_from_state_func>>('rust_is_validator_from_state');
    final myFunction = fnPointer.asFunction<DartIsValidatorFromState>();
    return myFunction(blob.toNativeUtf8());
  }

  @override
  bool is_operator_from_state(String blob) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_is_operator_from_state_func>>('rust_is_operator_from_state');
    final myFunction = fnPointer.asFunction<DartIsOperatorFromState>();
    return myFunction(blob.toNativeUtf8());
  }

  @override
  String claim_make_whole(String mnem, int sequence_num) {
    final fnPointer = _lib!.lookup<NativeFunction<rust_claim_make_whole_func>>('rust_claim_make_whole');
    var myFunction = fnPointer.asFunction<DartClaimMakeWhole>();
    Pointer<Utf8> signedTx = myFunction(sequence_num, mnem.toNativeUtf8());
    String finalSignedTx = signedTx != null ? ""+signedTx.toDartString() : "null";
    _rust_cstr_free(signedTx);
    return finalSignedTx;
  }

}
