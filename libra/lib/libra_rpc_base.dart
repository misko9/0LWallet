import 'dart:convert';
import 'package:flutter/material.dart';
import 'endpoints.dart';

// --------- Baseline RPC --------------
class LibraRpcBase {
  // Baseline RPC, use this for each request
  static generateRpc(String method, List<Object> params) async {
    // encode the post body as JSON and then UTF8 bytes
    var jsonStr = json.encode({
      "jsonrpc":"2.0",
      "method":method,
      "params":params,
      "id":1,
    });
    var dataBytes = utf8.encode(jsonStr);
    //debugPrint("RPC json req: "+jsonStr);
    //debugPrint(dataBytes.toString());

    // use the low level HttpClient to get control of the header case
    final clientList = await Endpoints.getEndpoint();
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
}