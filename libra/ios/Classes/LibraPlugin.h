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
void rust_cstr_free(char *s);
