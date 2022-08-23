import 'platform_impl/stub_libra.dart'
    if (dart.library.io) 'platform_impl/mobile_libra.dart'
    if (dart.library.html) 'platform_impl/web_libra.dart';


class Libra {
  static String get_address_from_mnem(String mnem) {
    return LibraImpl().get_address_from_mnem(mnem);
  }

  static bool is_mnem_valid(String mnem) {
    return LibraImpl().is_mnem_valid(mnem);
  }

  static String balance_transfer(String dest_addr, int coins, String mnem, int sequence_num) {
    return LibraImpl().balance_transfer(dest_addr, coins, mnem, sequence_num);
  }

  static String community_balance_transfer(String dest_addr, int coins, String mnem, int sequence_num) {
    return LibraImpl().community_balance_transfer(dest_addr, coins, mnem, sequence_num);
  }

  static int get_unlocked_from_state(String blob) {
    return LibraImpl().get_unlocked_from_state(blob);
  }

  static int get_transferred_from_state(String blob) {
    return LibraImpl().get_transferred_from_state(blob);
  }

  static String get_wallet_type_from_state(String blob) {
    return LibraImpl().get_wallet_type_from_state(blob);
  }

  static String get_vouchers_from_state(String blob) {
    return LibraImpl().get_vouchers_from_state(blob);
  }

  static String get_ancestry_from_state(String blob) {
    return LibraImpl().get_ancestry_from_state(blob);
  }

  static int get_make_whole_credits_from_state(String blob) {
    return LibraImpl().get_make_whole_credits_from_state(blob);
  }

  static bool is_make_whole_claimed_from_state(String blob) {
    return LibraImpl().is_make_whole_claimed_from_state(blob);
  }

  static bool is_validator_from_state(String blob) {
    return LibraImpl().is_validator_from_state(blob);
  }

  static bool is_operator_from_state(String blob) {
    return LibraImpl().is_operator_from_state(blob);
  }

  static String claim_make_whole(String mnem, int sequence_num) {
    return LibraImpl().claim_make_whole(mnem, sequence_num);
  }

}
