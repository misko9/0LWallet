import 'package:bip39/bip39.dart' as bip39;
import 'base_libra.dart';

class LibraImpl extends BaseLibra {
  @override
  String balance_transfer(String dest_addr, int coins, String mnem, int sequence_num) {
    // TODO: implement balance_transfer
    return "";
    //throw UnimplementedError();
  }

  @override
  String claim_make_whole(String mnem, int sequence_num) {
    // TODO: implement claim_make_whole
    return "";
    //throw UnimplementedError();
  }

  @override
  String community_balance_transfer(String dest_addr, int coins, String mnem, int sequence_num) {
    // TODO: implement community_balance_transfer
    return "";
    //throw UnimplementedError();
  }

  @override
  String get_address_from_mnem(String mnem) {
    // TODO: implement get_address_from_mnem
    return "12345678901234567890123456789012";
    //throw UnimplementedError();
  }

  @override
  String get_ancestry_from_state(String blob) {
    // TODO: implement get_ancestry_from_state
    return "";
    //throw UnimplementedError();
  }

  @override
  int get_make_whole_credits_from_state(String blob) {
    // TODO: implement get_make_whole_credits_from_state
    return 0;
    //throw UnimplementedError();
  }

  @override
  int get_transferred_from_state(String blob) {
    // TODO: implement get_transferred_from_state
    return 0;
    //throw UnimplementedError();
  }

  @override
  int get_unlocked_from_state(String blob) {
    // TODO: implement get_unlocked_from_state
    return 0;
    //throw UnimplementedError();
  }

  @override
  String get_vouchers_from_state(String blob) {
    // TODO: implement get_vouchers_from_state
    return "";
    //throw UnimplementedError();
  }

  @override
  String get_wallet_type_from_state(String blob) {
    // TODO: implement get_wallet_type_from_state
    return "normal";
    //throw UnimplementedError();
  }

  @override
  bool is_make_whole_claimed_from_state(String blob) {
    // TODO: implement is_make_whole_claimed_from_state
    return false;
    //throw UnimplementedError();
  }

  @override
  bool is_mnem_valid(String mnem) {
    return bip39.validateMnemonic(mnem);
  }

  @override
  bool is_operator_from_state(String blob) {
    // TODO: implement is_operator_from_state
    return false;
    //throw UnimplementedError();
  }

  @override
  bool is_validator_from_state(String blob) {
    // TODO: implement is_validator_from_state
    return false;
    //throw UnimplementedError();
  }

}