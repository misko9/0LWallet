import 'dart:convert';

class Account {
  String name;
  String addr;
  int towerHeight;
  double balance;
  String walletType;
  int seqNum;
  int epochProofs;
  int lastEpochMined;
  bool watchOnly;
  DateTime lastUpdated;
  double makeWhole;
  String ancestry;
  double unlocked;
  double transferred;
  bool isValidator;
  bool isOperator;
  String vouchers;

  Account({
    required this.name,
    required this.addr,
    this.towerHeight = 0,
    this.balance = 0.0,
    this.walletType = 'normal',
    this.seqNum = 0,
    this.epochProofs = 0,
    this.lastEpochMined = 0,
    required this.watchOnly,
    this.makeWhole = 0.0,
    this.ancestry = "",
    this.unlocked = 0.0,
    this.transferred = 0.0,
    this.isValidator = false,
    this.isOperator = false,
    this.vouchers = "",
  }) : lastUpdated = DateTime(1969);

  factory Account.fromJson(addr, Map<String, dynamic> jsonData) {
    return Account(
      addr: addr,
      name: jsonData['name'],
      towerHeight: jsonData['towerHeight'],
      balance: jsonData['balance'],
      walletType: jsonData['walletType'],
      seqNum: jsonData['seqNum'] ?? 0,
      epochProofs: jsonData['epochProofs'] ?? 0,
      lastEpochMined: jsonData['lastEpochMined'] ?? 0,
      watchOnly: jsonData['watchOnly'] ?? false,
      makeWhole: jsonData['makeWhole'] ?? 0.0,
      ancestry: jsonData['ancestry'] ?? "",
      unlocked: jsonData['unlocked'] ?? 0.0,
      transferred: jsonData['transferred'] ?? 0.0,
      isValidator: jsonData['isValidator'] ?? false,
      isOperator: jsonData['isOperator'] ?? false,
      vouchers: jsonData['vouchers'] ?? "",
    );
  }

  static Map<String, dynamic> toMap(Account account) => {
    'name': account.name,
    'towerHeight': account.towerHeight,
    'balance': account.balance,
    'walletType': account.walletType,
    'seqNum': account.seqNum,
    'epochProofs': account.epochProofs,
    'lastEpochMined': account.lastEpochMined,
    'watchOnly': account.watchOnly,
    'makeWhole': account.makeWhole,
    'ancestry': account.ancestry,
    'unlocked': account.unlocked,
    'transferred': account.transferred,
    'isValidator': account.isValidator,
    'isOperator': account.isOperator,
    'vouchers': account.vouchers,
  };
  static String serialize(Account account) => jsonEncode(Account.toMap(account));
  static Account deserialize(String addr, String json) => Account.fromJson(addr, jsonDecode(json));
}