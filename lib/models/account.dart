import 'dart:convert';

class Account {
  String name;
  String addr;
  int towerHeight;
  double balance;
  String walletType;
  int seqNum;
  int epochProofs;

  Account({
    required this.name,
    this.addr = '',
    this.towerHeight = 0,
    this.balance = 0.0,
    this.walletType = 'normal',
    this.seqNum = 0,
    this.epochProofs = 0,
  });

  factory Account.fromJson(addr, Map<String, dynamic> jsonData) {
    return Account(
      addr: addr,
      name: jsonData['name'],
      towerHeight: jsonData['towerHeight'],
      balance: jsonData['balance'],
      walletType: jsonData['walletType'],
      seqNum: jsonData['seqNum'] ?? 0,
      epochProofs: jsonData['epochProofs'] ?? 0,
    );
  }

  static Map<String, dynamic> toMap(Account account) => {
    'name': account.name,
    'towerHeight': account.towerHeight,
    'balance': account.balance,
    'walletType': account.walletType,
    'seqNum': account.seqNum,
    'epochProofs': account.epochProofs,
  };
  static String serialize(Account account) => jsonEncode(Account.toMap(account));
  static Account deserialize(String addr, String json) => Account.fromJson(addr, jsonDecode(json));
}