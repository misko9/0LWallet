#import <Flutter/Flutter.h>

@interface LibraPlugin : NSObject<FlutterPlugin>
@end

//int64_t rust_add(int64_t a, int64_t b);

//char *rust_greeting(const char *to);

/// default way accounts get initialized in Carpe
char *get_addr_from_mnem(const char *mnem);

bool is_mnem_valid(const char *mnem_char);


char *rust_balance_transfer(uint64_t coins,
                            uint64_t sequence_num,
                            const char *dest_addr,
                            const char *mnem);
char *rust_community_balance_transfer(uint64_t coins, uint64_t sequence_num, const char *dest_addr, const char *mnem);
char *rust_claim_make_whole(uint64_t sequence_num, const char *mnem);
uint64_t rust_get_make_whole_credits_from_state(const char *blob);
bool rust_is_make_whole_claimed_from_state(const char *blob);
char *rust_get_ancestry_from_state(const char *blob);
char *rust_get_vouchers_from_state(const char *blob);
char *rust_get_wallet_type_from_state(const char *blob);
bool rust_is_validator_from_state(const char *blob);
bool rust_is_operator_from_state(const char *blob);
uint64_t rust_get_unlocked_from_state(const char *blob);
uint64_t rust_get_transferred_from_state(const char *blob);
void rust_cstr_free(char *s);
