import 'dart:convert';

class Account {
  String name;
  String addr;
  int towerHeight;
  double balance;
  String walletType;

  Account({
    required this.name,
    this.addr = '',
    this.towerHeight = 0,
    this.balance = 0.0,
    this.walletType = 'normal',
  });

  factory Account.fromJson(addr, Map<String, dynamic> jsonData) {
    return Account(
      addr: addr,
      name: jsonData['name'],
      towerHeight: jsonData['towerHeight'],
      balance: jsonData['balance'],
      walletType: jsonData['walletType'],
    );
  }

  static Map<String, dynamic> toMap(Account account) => {
    'name': account.name,
    'towerHeight': account.towerHeight,
    'balance': account.balance,
    'walletType': account.walletType,
  };
  static String serialize(Account account) => jsonEncode(Account.toMap(account));
  static Account deserialize(String addr, String json) => Account.fromJson(addr, jsonDecode(json));
}