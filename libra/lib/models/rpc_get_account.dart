/// diem_chain_id : 1
/// diem_ledger_version : 29776133
/// diem_ledger_timestampusec : 1646518517475845
/// jsonrpc : "2.0"
/// id : 1
/// result : {"address":"46d34624680c99c320ae4859abd529ee","balances":[{"amount":805949678,"currency":"GAS"}],"sequence_number":999,"authentication_key":"051c302467df6469d3572973e5fdb66446d34624680c99c320ae4859abd529ee","sent_events_key":"010000000000000046d34624680c99c320ae4859abd529ee","received_events_key":"000000000000000046d34624680c99c320ae4859abd529ee","delegated_key_rotation_capability":false,"delegated_withdrawal_capability":false,"is_frozen":false,"role":{"type":"unknown"},"version":29776133}

class RpcGetAccount {
  RpcGetAccount({
      required int diemChainId,
      required int diemLedgerVersion,
      required int diemLedgerTimestampusec,
      required String jsonrpc,
      required int id,
      Result? result,}){
    _diemChainId = diemChainId;
    _diemLedgerVersion = diemLedgerVersion;
    _diemLedgerTimestampusec = diemLedgerTimestampusec;
    _jsonrpc = jsonrpc;
    _id = id;
    _result = result;
}

  RpcGetAccount.fromJson(dynamic json) {
    _diemChainId = json['diem_chain_id'];
    _diemLedgerVersion = json['diem_ledger_version'];
    _diemLedgerTimestampusec = json['diem_ledger_timestampusec'];
    _jsonrpc = json['jsonrpc'];
    _id = json['id'];
    _result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  late int _diemChainId;
  late int _diemLedgerVersion;
  late int _diemLedgerTimestampusec;
  late String _jsonrpc;
  late int _id;
  Result? _result;

  int get diemChainId => _diemChainId;
  int get diemLedgerVersion => _diemLedgerVersion;
  int get diemLedgerTimestampusec => _diemLedgerTimestampusec;
  String get jsonrpc => _jsonrpc;
  int get id => _id;
  Result? get result => _result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['diem_chain_id'] = _diemChainId;
    map['diem_ledger_version'] = _diemLedgerVersion;
    map['diem_ledger_timestampusec'] = _diemLedgerTimestampusec;
    map['jsonrpc'] = _jsonrpc;
    map['id'] = _id;
    if (_result != null) {
      map['result'] = _result?.toJson();
    }
    return map;
  }

}

/// address : "46d34624680c99c320ae4859abd529ee"
/// balances : [{"amount":805949678,"currency":"GAS"}]
/// sequence_number : 999
/// authentication_key : "051c302467df6469d3572973e5fdb66446d34624680c99c320ae4859abd529ee"
/// sent_events_key : "010000000000000046d34624680c99c320ae4859abd529ee"
/// received_events_key : "000000000000000046d34624680c99c320ae4859abd529ee"
/// delegated_key_rotation_capability : false
/// delegated_withdrawal_capability : false
/// is_frozen : false
/// role : {"type":"unknown"}
/// version : 29776133

class Result {
  Result({
      required String address,
      required List<Balances> balances,
      required int sequenceNumber,
      required String authenticationKey,
      required String sentEventsKey,
      required String receivedEventsKey,
      required bool delegatedKeyRotationCapability,
      required bool delegatedWithdrawalCapability,
      required bool isFrozen,
      required Role role,
      required int version,}){
    _address = address;
    _balances = balances;
    _sequenceNumber = sequenceNumber;
    _authenticationKey = authenticationKey;
    _sentEventsKey = sentEventsKey;
    _receivedEventsKey = receivedEventsKey;
    _delegatedKeyRotationCapability = delegatedKeyRotationCapability;
    _delegatedWithdrawalCapability = delegatedWithdrawalCapability;
    _isFrozen = isFrozen;
    _role = role;
    _version = version;
}

  Result.fromJson(dynamic json) {
    _address = json['address'];
    if (json['balances'] != null) {
      _balances = [];
      json['balances'].forEach((v) {
        _balances.add(Balances.fromJson(v));
      });
    }
    _sequenceNumber = json['sequence_number'];
    _authenticationKey = json['authentication_key'];
    _sentEventsKey = json['sent_events_key'];
    _receivedEventsKey = json['received_events_key'];
    _delegatedKeyRotationCapability = json['delegated_key_rotation_capability'];
    _delegatedWithdrawalCapability = json['delegated_withdrawal_capability'];
    _isFrozen = json['is_frozen'];
    _role = json['role'] != null ? Role.fromJson(json['role']) : null;
    _version = json['version'];
  }
  late String _address;
  late List<Balances> _balances;
  late int _sequenceNumber;
  late String _authenticationKey;
  late String _sentEventsKey;
  late String _receivedEventsKey;
  late bool _delegatedKeyRotationCapability;
  late bool _delegatedWithdrawalCapability;
  late bool _isFrozen;
  Role? _role;
  late int _version;

  String get address => _address;
  List<Balances> get balances => _balances;
  int get sequenceNumber => _sequenceNumber;
  String get authenticationKey => _authenticationKey;
  String get sentEventsKey => _sentEventsKey;
  String get receivedEventsKey => _receivedEventsKey;
  bool get delegatedKeyRotationCapability => _delegatedKeyRotationCapability;
  bool get delegatedWithdrawalCapability => _delegatedWithdrawalCapability;
  bool get isFrozen => _isFrozen;
  Role? get role => _role;
  int get version => _version;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['address'] = _address;
    if (_balances != null) {
      map['balances'] = _balances.map((v) => v.toJson()).toList();
    }
    map['sequence_number'] = _sequenceNumber;
    map['authentication_key'] = _authenticationKey;
    map['sent_events_key'] = _sentEventsKey;
    map['received_events_key'] = _receivedEventsKey;
    map['delegated_key_rotation_capability'] = _delegatedKeyRotationCapability;
    map['delegated_withdrawal_capability'] = _delegatedWithdrawalCapability;
    map['is_frozen'] = _isFrozen;
    if (_role != null) {
      map['role'] = _role!.toJson();
    }
    map['version'] = _version;
    return map;
  }

}

/// type : "unknown"

class Role {
  Role({
      required String type,}){
    _type = type;
}

  Role.fromJson(dynamic json) {
    _type = json['type'];
  }
  late String _type;

  String get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = _type;
    return map;
  }

}

/// amount : 805949678
/// currency : "GAS"

class Balances {
  Balances({
      required int amount,
      required String currency,}){
    _amount = amount;
    _currency = currency;
}

  Balances.fromJson(dynamic json) {
    _amount = json['amount'];
    _currency = json['currency'];
  }
  late int _amount;
  late String _currency;

  int get amount => _amount;
  String get currency => _currency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['amount'] = _amount;
    map['currency'] = _currency;
    return map;
  }

}