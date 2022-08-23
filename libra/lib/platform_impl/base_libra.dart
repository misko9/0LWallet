abstract class BaseLibra {
  String get_address_from_mnem(String mnem);

  bool is_mnem_valid(String mnem);

  String balance_transfer(
      String dest_addr, int coins, String mnem, int sequence_num);

  String community_balance_transfer(
      String dest_addr, int coins, String mnem, int sequence_num);

  int get_unlocked_from_state(String blob);

  int get_transferred_from_state(String blob);

  String get_wallet_type_from_state(String blob);

  String get_vouchers_from_state(String blob);

  String get_ancestry_from_state(String blob);

  int get_make_whole_credits_from_state(String blob);

  bool is_make_whole_claimed_from_state(String blob);

  bool is_validator_from_state(String blob);

  bool is_operator_from_state(String blob);

  String claim_make_whole(String mnem, int sequence_num);
}
