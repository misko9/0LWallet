import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'models/rpc_get_account.dart';
import 'models/rpc_get_tower_state_view.dart';

enum SubmitStatus {
  okay,
  errorNot200,

}

class LibraRpc {
  static const SCALING_FACTOR = 1000000; // 1_000_000
  static bool testnetEnabled = false;
  static String overridePeers = '';

  static getAccountBalance(String address) async {
    var response = await _getAccountRpc(address);
    double balance = -1.0;
    if (response == null) {
      return balance;
    }
    // turn the streamed response back to a string so that it can be parsed as JSON
    final responseBody = await response.transform(utf8.decoder).join();
    debugPrint("getAccountBalance" + responseBody);

    if(response.statusCode==200){
      var account = RpcGetAccount.fromJson(jsonDecode(responseBody)).result;
      if (account != null && account.balances != null && account.balances.isNotEmpty) {
        balance = account.balances.firstWhere((element) => element.currency == "GAS")
            .amount.toDouble()/SCALING_FACTOR;
      }
    }
    return balance;
  }

  static getAccountSeqNum(String address) async {
    var response = await _getAccountRpc(address);
    int sequenceNum = -1;
    if (response == null) {
      return sequenceNum;
    }
    // turn the streamed response back to a string so that it can be parsed as JSON
    final responseBody = await response.transform(utf8.decoder).join();
    debugPrint("getAccountSeqNum" + responseBody);

    if(response.statusCode==200){
      var account = RpcGetAccount.fromJson(jsonDecode(responseBody)).result;
      if (account != null && account.sequenceNumber >= 0) {
        sequenceNum = account.sequenceNumber;
      }
    }
    return sequenceNum;
  }

  static getTowerHeight(String address) async {
    var response = await _getTowerStateViewRpc(address);
    var tower_height = -1;
    if (response == null) {
      return tower_height;
    }

    // turn the streamed response back to a string so that it can be parsed as JSON
    final responseBody = await response.transform(utf8.decoder).join();
    debugPrint("getTowerHeight" + responseBody);

    if(response.statusCode==200) {
      var result = rpcGetTowerStateViewFromJson(responseBody).result;
      if (result != null && result.verifiedTowerHeight != null) {
        tower_height = result.verifiedTowerHeight!.toInt();
      }
    }
    return tower_height;
  }

// --------- Available RPC methods ----------

  static _getAccountRpc(String address) async {
    return await _generateRpc("get_account", [address,]);
  }

  static _getTowerStateViewRpc(String address) async {
    return await _generateRpc("get_tower_state_view", [address,]);
  }

  static getAccountTransaction(String address, int seqNum) async {
    var response = await _generateRpc(
        "get_account_transaction",
        [address, seqNum, true]
    );
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
    var response = await _generateRpc("submit", [signedTx,]);
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

// --------- Baseline RPC --------------

  // Baseline RPC, use this for each request
  static _generateRpc(String method, List<Object> params) async {
    // encode the post body as JSON and then UTF8 bytes
    var jsonStr = json.encode({
      "jsonrpc":"2.0",
      "method":method,
      "params":params,
      "id":1,
    });
    var dataBytes = utf8.encode(jsonStr);
    debugPrint("RPC json req: "+jsonStr);
    debugPrint(dataBytes.toString());

    // use the low level HttpClient to get control of the header case
    final clientList = await _getRequest();
    if (clientList == null) {
      return null;
    }
    var client = clientList[0];
    var request = clientList[1];

    debugPrint("after client.post");
    // manually add the content length header to preserve its case
    request.headers.add(
      'Content-Type', // note the upper case string - try it with lower case (spoiler it fails)
      "application/json",
      preserveHeaderCase: true,
    );
    request.headers.add(
      'Content-Length', // note the upper case string - try it with lower case (spoiler it fails)
      dataBytes.length.toString(),
      preserveHeaderCase: true,
    );
    // optional - add other headers (e.g. Auth) here
    // request.headers.add(/*some other header*/);

    // send the body bytes
    request.add(dataBytes);
    debugPrint("after request.add");

    // 'close' the request to send it, and get a response
    final response = await request.close();
    debugPrint("after request.close");
    debugPrint(response.statusCode.toString());

    // close the client (or re-use it if you prefer)
    client.close();
    return response;
  }

  // Update to rotate playlist
  static _getRequest() async {
    final mainnetIps = [
      //'35.184.98.21',
      '135.181.118.28',
      //'165.232.136.149',
      '176.57.189.120',
      //'138.197.152.1',
      '0l.fullnode.gnazar.io',
    ];

    final testnetIps = [
      '148.251.89.142', //alice
      '137.184.191.201', //bob
      '91.229.245.110', //carol
    ];

    final urls = testnetEnabled ? testnetIps : mainnetIps;

    if (overridePeers.isEmpty) {
      // generates a new random index
      final _random = Random().nextInt(urls.length);
      for (int i = 0; i < urls.length; i++) {
        var client = HttpClient();
        var index = (i + _random) % urls.length;
        try {
          var request = await client.post(urls[index], 8080, '');
          debugPrint("No SocketException with " + urls[index]);
          return [client, request];
        } on SocketException catch (_) {
          client.close();
          debugPrint("SocketException with " + urls[index]);
          continue;
        }
      }
    } else {
      var client = HttpClient();
      var uri = Uri.tryParse(overridePeers);
      if (uri != null) {
        try {
          var request = await client.post(uri.host, uri.port, '');
          debugPrint("No SocketException with " + overridePeers);
          return [client, request];
        } on SocketException catch (_) {
          client.close();
          debugPrint("SocketException with " + overridePeers);
        }
      }
    }
    return null;
  }

  static isUrlReachable(String url) async {
    var client = HttpClient();
    var uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    try {
      await client.post(uri.host, uri.port, '');
    } on SocketException catch (_) {
      client.close();
      debugPrint("SocketException with "+url);
      return false;
    }
    debugPrint("No SocketException with "+url);
    client.close();
    return true;
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