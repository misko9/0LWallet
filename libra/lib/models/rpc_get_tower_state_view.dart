import 'dart:convert';
/// diem_chain_id : 1
/// diem_ledger_version : 29836752
/// diem_ledger_timestampusec : 1646542444738511
/// jsonrpc : "2.0"
/// id : 1
/// result : {"previous_proof_hash":"78839e823a2b1e77bb2234f923958195878012f1f6dae87cb41510bc233c4eb8","verified_tower_height":1003,"latest_epoch_mining":131,"count_proofs_in_epoch":10,"epochs_validating_and_mining":0,"contiguous_epochs_validating_and_mining":0,"epochs_since_last_account_creation":0,"actual_count_proofs_in_epoch":10}

RpcGetTowerStateView rpcGetTowerStateViewFromJson(String str) => RpcGetTowerStateView.fromJson(json.decode(str));
String rpcGetTowerStateViewToJson(RpcGetTowerStateView data) => json.encode(data.toJson());
class RpcGetTowerStateView {
  RpcGetTowerStateView({
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

  RpcGetTowerStateView.fromJson(dynamic json) {
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

/// previous_proof_hash : "78839e823a2b1e77bb2234f923958195878012f1f6dae87cb41510bc233c4eb8"
/// verified_tower_height : 1003
/// latest_epoch_mining : 131
/// count_proofs_in_epoch : 10
/// epochs_validating_and_mining : 0
/// contiguous_epochs_validating_and_mining : 0
/// epochs_since_last_account_creation : 0
/// actual_count_proofs_in_epoch : 10

Result resultFromJson(String str) => Result.fromJson(json.decode(str));
String resultToJson(Result data) => json.encode(data.toJson());
class Result {
  Result({
      String? previousProofHash, 
      int? verifiedTowerHeight, 
      int? latestEpochMining, 
      int? countProofsInEpoch, 
      int? epochsValidatingAndMining, 
      int? contiguousEpochsValidatingAndMining, 
      int? epochsSinceLastAccountCreation, 
      int? actualCountProofsInEpoch,}){
    _previousProofHash = previousProofHash;
    _verifiedTowerHeight = verifiedTowerHeight;
    _latestEpochMining = latestEpochMining;
    _countProofsInEpoch = countProofsInEpoch;
    _epochsValidatingAndMining = epochsValidatingAndMining;
    _contiguousEpochsValidatingAndMining = contiguousEpochsValidatingAndMining;
    _epochsSinceLastAccountCreation = epochsSinceLastAccountCreation;
    _actualCountProofsInEpoch = actualCountProofsInEpoch;
}

  Result.fromJson(dynamic json) {
    _previousProofHash = json['previous_proof_hash'];
    _verifiedTowerHeight = json['verified_tower_height'];
    _latestEpochMining = json['latest_epoch_mining'];
    _countProofsInEpoch = json['count_proofs_in_epoch'];
    _epochsValidatingAndMining = json['epochs_validating_and_mining'];
    _contiguousEpochsValidatingAndMining = json['contiguous_epochs_validating_and_mining'];
    _epochsSinceLastAccountCreation = json['epochs_since_last_account_creation'];
    _actualCountProofsInEpoch = json['actual_count_proofs_in_epoch'];
  }
  String? _previousProofHash;
  int? _verifiedTowerHeight;
  int? _latestEpochMining;
  int? _countProofsInEpoch;
  int? _epochsValidatingAndMining;
  int? _contiguousEpochsValidatingAndMining;
  int? _epochsSinceLastAccountCreation;
  int? _actualCountProofsInEpoch;

  String? get previousProofHash => _previousProofHash;
  int? get verifiedTowerHeight => _verifiedTowerHeight;
  int? get latestEpochMining => _latestEpochMining;
  int? get countProofsInEpoch => _countProofsInEpoch;
  int? get epochsValidatingAndMining => _epochsValidatingAndMining;
  int? get contiguousEpochsValidatingAndMining => _contiguousEpochsValidatingAndMining;
  int? get epochsSinceLastAccountCreation => _epochsSinceLastAccountCreation;
  int? get actualCountProofsInEpoch => _actualCountProofsInEpoch;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['previous_proof_hash'] = _previousProofHash;
    map['verified_tower_height'] = _verifiedTowerHeight;
    map['latest_epoch_mining'] = _latestEpochMining;
    map['count_proofs_in_epoch'] = _countProofsInEpoch;
    map['epochs_validating_and_mining'] = _epochsValidatingAndMining;
    map['contiguous_epochs_validating_and_mining'] = _contiguousEpochsValidatingAndMining;
    map['epochs_since_last_account_creation'] = _epochsSinceLastAccountCreation;
    map['actual_count_proofs_in_epoch'] = _actualCountProofsInEpoch;
    return map;
  }

}