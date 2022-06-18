import 'dart:convert';
/// diem_chain_id : 1
/// diem_ledger_version : 48700487
/// diem_ledger_timestampusec : 1655410753391019
/// jsonrpc : "2.0"
/// id : 1
/// result : {"waypoint":"48700487:9634962f9eef912f1ee955c0d9e7f5d41f1381969bb3c02dcc570dc3101995aa"}

RpcGetWaypointView rpcGetWaypointViewFromJson(String str) => RpcGetWaypointView.fromJson(json.decode(str));
String rpcGetWaypointViewToJson(RpcGetWaypointView data) => json.encode(data.toJson());
class RpcGetWaypointView {
  RpcGetWaypointView({
      int? diemChainId, 
      int? diemLedgerVersion, 
      int? diemLedgerTimestampusec, 
      String? jsonrpc, 
      int? id, 
      Result? result,}){
    _diemChainId = diemChainId;
    _diemLedgerVersion = diemLedgerVersion;
    _diemLedgerTimestampusec = diemLedgerTimestampusec;
    _jsonrpc = jsonrpc;
    _id = id;
    _result = result;
}

  RpcGetWaypointView.fromJson(dynamic json) {
    _diemChainId = json['diem_chain_id'];
    _diemLedgerVersion = json['diem_ledger_version'];
    _diemLedgerTimestampusec = json['diem_ledger_timestampusec'];
    _jsonrpc = json['jsonrpc'];
    _id = json['id'];
    _result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  int? _diemChainId;
  int? _diemLedgerVersion;
  int? _diemLedgerTimestampusec;
  String? _jsonrpc;
  int? _id;
  Result? _result;
RpcGetWaypointView copyWith({  int? diemChainId,
  int? diemLedgerVersion,
  int? diemLedgerTimestampusec,
  String? jsonrpc,
  int? id,
  Result? result,
}) => RpcGetWaypointView(  diemChainId: diemChainId ?? _diemChainId,
  diemLedgerVersion: diemLedgerVersion ?? _diemLedgerVersion,
  diemLedgerTimestampusec: diemLedgerTimestampusec ?? _diemLedgerTimestampusec,
  jsonrpc: jsonrpc ?? _jsonrpc,
  id: id ?? _id,
  result: result ?? _result,
);
  int? get diemChainId => _diemChainId;
  int? get diemLedgerVersion => _diemLedgerVersion;
  int? get diemLedgerTimestampusec => _diemLedgerTimestampusec;
  String? get jsonrpc => _jsonrpc;
  int? get id => _id;
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

/// waypoint : "48700487:9634962f9eef912f1ee955c0d9e7f5d41f1381969bb3c02dcc570dc3101995aa"

Result resultFromJson(String str) => Result.fromJson(json.decode(str));
String resultToJson(Result data) => json.encode(data.toJson());
class Result {
  Result({
      String? waypoint,}){
    _waypoint = waypoint;
}

  Result.fromJson(dynamic json) {
    _waypoint = json['waypoint'];
  }
  String? _waypoint;
Result copyWith({  String? waypoint,
}) => Result(  waypoint: waypoint ?? _waypoint,
);
  String? get waypoint => _waypoint;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['waypoint'] = _waypoint;
    return map;
  }

}