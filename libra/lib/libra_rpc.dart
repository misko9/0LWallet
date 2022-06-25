import 'dart:convert';

import 'package:flutter/material.dart';
import 'libra_rpc_base.dart';
import 'models/rpc_get_account.dart';
import 'models/rpc_get_tower_state_view.dart';

enum SubmitStatus {
  okay,
  errorNot200,
}

class LibraRpc {
// --------- Available RPC methods ----------
  static getAccountRpc(String address) async {
    var response = await LibraRpcBase.generateRpc("get_account", [address,]);
    // turn the streamed response back to a string so that it can be parsed as JSON
    RpcGetAccount? account;
    //RpcGetAccount account = RpcGetAccount(diemChainId: 0, diemLedgerVersion: 0, diemLedgerTimestampusec: 0, jsonrpc: "", id: 0);
    if(response != null && response.statusCode==200){
      final responseBody = await response.transform(utf8.decoder).join();
      debugPrint("getAccountRpc" + responseBody);
      account = RpcGetAccount.fromJson(jsonDecode(responseBody));
    }
    return account;
  }

  static getTowerStateViewRpc(String address) async {
    var response = await LibraRpcBase.generateRpc("get_tower_state_view", [address,]);
    // turn the streamed response back to a string so that it can be parsed as JSON
    RpcGetTowerStateView? towerStateView;
    if(response != null && response.statusCode==200) {
      final responseBody = await response.transform(utf8.decoder).join();
      debugPrint("getTowerStateViewRpc" + responseBody);
      towerStateView = rpcGetTowerStateViewFromJson(responseBody);
    }
    return towerStateView;
  }

  static getAccountTransaction(String address, int seqNum) async {
    var response = await LibraRpcBase.generateRpc(
        "get_account_transaction",
        [address, seqNum, true]
    );
    if (response == null) {
      return -99999;
    }

    // turn the streamed response back to a string so that it can be parsed as JSON
    final responseBody = await response.transform(utf8.decoder).join();
    debugPrint("getAccountTransactions $responseBody");

    int status = response.statusCode;
    if(status==200){
      debugPrint("Submit status code == 200");
      if(responseBody.toString().contains("error")) {
        status = _getStatusCode(responseBody.toString());
      }
      if(responseBody.toString().contains("transaction")) {
        status = 0;
        if(responseBody.toString().contains("move_abort")) {
          status = -127;
          if(responseBody.toString().contains("null")) {
            status = -128;
          }
        }
      }
    } else {
      debugPrint("Submit error");
    }
    return status;
  }

  static submitRpc(String signedTx) async {
    var response = await LibraRpcBase.generateRpc("submit", [signedTx,]);
    if (response == null) {
      return -99999;
    }

    // turn the streamed response back to a string so that it can be parsed as JSON
    final responseBody = await response.transform(utf8.decoder).join();
    debugPrint(responseBody);

    int status = response.statusCode;
    if(status==200){
      debugPrint("Submit status code == 200");
      if(responseBody.toString().contains("error")) {
        status = _getStatusCode(responseBody.toString());
      }
      // May still have an error...
    } else {
      debugPrint("Submit error");
    }
    return status;
  }

/*  -32000	Default server error
  -32001	VM validation error
  -32002	VM verification error
  -32003	VM invariant violation error
  -32004	VM deserialization error
  -32005	VM execution error
  -32006	VM unknown error
  -32007	Mempool error: invalid sequence number
  -32008	Mempool is full error
  -32009	Mempool error: account reached max capacity per account
  -32010	Mempool error: invalid update (only gas price increase is allowed)
  -32011	Mempool error: transaction did not pass VM validation
  -32012	Unknown error
  -32600	standard invalid request error
  -32601	method not found or not specified
  -32602	invalid params
  -32604	invalid format
  */
  static _getStatusCode(String responseBody) {
    if(responseBody.contains("-32000")) {
      return -32000;
    } else if (responseBody.contains("-32001")) {
      return -32001;
    } else if (responseBody.contains("-32002")) {
      return -32002;
    } else if (responseBody.contains("-32003")) {
      return -32003;
    } else if (responseBody.contains("-32004")) {
      return -32004;
    } else if (responseBody.contains("-32005")) {
      return -32005;
    } else if (responseBody.contains("-32006")) {
      return -32006;
    } else if (responseBody.contains("-32007")) {
      return -32007;
    } else if (responseBody.contains("-32008")) {
      return -32008;
    } else if (responseBody.contains("-32009")) {
      return -32009;
    } else if (responseBody.contains("-32010")) {
      return -32010;
    } else if (responseBody.contains("-32011")) {
      return -32011;
    } else if (responseBody.contains("-32012")) {
      return -32012;
    } else if (responseBody.contains("-32600")) {
      return -32600;
    } else if (responseBody.contains("-32601")) {
      return -32601;
    } else if (responseBody.contains("-32602")) {
      return -32602;
    } else if (responseBody.contains("-32604")) {
      return -32604;
    }
    return -1;
  }
}