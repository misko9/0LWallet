import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:synchronized/synchronized.dart';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'models/rpc_get_waypoint_view.dart';
import 'models/endpoint.dart';

final staticMainnetIps = [
  '63.229.234.76', // gnudrew 6
  '104.154.120.174', // OD 8
  '65.108.195.43', // svanakin 30
  '135.181.118.28', // daniyal 22
  '154.12.239.62', // mb 10
  '35.184.98.21', // OD 7
  '147.182.247.247', // thenateway 9
  '63.229.234.77', // gnudrew 7
  '65.108.143.43', // svanakin 27
  'fullnode.letsmove.fun', // IdleZone 19
  '142.132.207.50', // bigbubabeast
  'ol.misko.io', // misko
  '52.15.236.78', // VM
];
final testnetNodes = [
  '148.251.89.142', //alice
  '137.184.191.201', //bob
  '91.229.245.110', //carol
];

class Endpoints {
  static DateTime lastUpdate = DateTime.utc(1969);
  static List<String> goodNodes = [];
  static List<Endpoint> currentEndpointList = [];
  static int rmsVersion = 0;
  static bool testnetEnabled = false;
  static String overridePeers = '';
  static var lock = Lock();

  static getEndpoint() async {
    if (overridePeers.isEmpty) {

      // Block all other requests until good enpoints have been updated
      await lock.synchronized(() async {
        if(timeToUpdate() || goodNodes.isEmpty) await updateEndpoints();
      });
      final urls = testnetEnabled ? testnetNodes : goodNodes;
      // generates a new random index
      if (urls.isNotEmpty) {
        final _random = Random().nextInt(urls.length);
        for (int i = 0; i < urls.length; i++) {
          var client = HttpClient();
          client.connectionTimeout = const Duration(seconds: 1);
          var index = (i + _random) % urls.length;
          try {
            var request = await client.post(urls[index], 8080, '');
            debugPrint("No SocketException with " + urls[index]);
            return [client, request];
          } on SocketException catch (_) {
            debugPrint("SocketException with " + urls[index]);
          } on Exception catch (_) {
            debugPrint("Exception with " + urls[index]);
          }
          client.close();
          continue;
        }
      }
    } else {
      var client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      var uri = Uri.tryParse(overridePeers);
      if (uri != null) {
        try {
          var request = await client.post(uri.host, uri.port, '');
          debugPrint("No (overridePeers) SocketException with " + overridePeers);
          return [client, request];
        } on SocketException catch (_) {
          debugPrint("SocketException (overridePeers) with " + overridePeers);
        } on Exception catch (_) {
          debugPrint("Exception (overridePeers) with " + overridePeers);
        }
      }
      client.close();
    }
    return null;

  }

  static updateEndpoints() async {
    FutureGroup<Endpoint> futureGroup = FutureGroup<Endpoint>();
    for (var element in staticMainnetIps) {
      futureGroup.add(checkEndpoint(element));
    }
    futureGroup.close();
    await futureGroup.future.then((List<Endpoint> endpointList) {
      int count = 0;
      int totalVersion = 0;
      int totalSquaredVersion = 0;
      int avgVersion = 0;
      int meanSquaredVersion = 0;
      rmsVersion = 0;
      currentEndpointList = endpointList;
      for (var endpoint in endpointList) {
        debugPrint("Endpoint: ${endpoint.url}, Version: ${endpoint.version}, is_avail: ${endpoint.is_avail}");
        if(endpoint.is_avail) {
          count++;
          totalVersion += endpoint.version;
        }
      }
      if(count > 0) {
        avgVersion = (totalVersion / count).floor();
      }
      count = 0;
      for (var endpoint in endpointList) {
        // Filter out nodes that aren't available and outliers for the calculation
        if(endpoint.is_avail && (endpoint.version > (avgVersion-10))) {
          count++;
          totalSquaredVersion += pow(endpoint.version, 2).toInt();
        }
      }
      if(count > 0) {
        meanSquaredVersion = (totalSquaredVersion / count).floor();
        rmsVersion = sqrt(meanSquaredVersion).floor();
      }
      debugPrint("RMS Version: $rmsVersion");
      if(rmsVersion > 0) {
        goodNodes = [];
        for (var endpoint in endpointList) {
          if(endpoint.is_avail && endpoint.version >= rmsVersion) {
            goodNodes.add(endpoint.url);
          }
        }
        debugPrint("Good node count: ${goodNodes.length}");
      }
    });
  }

  static Future<Endpoint> checkEndpoint(String endpointUrl) async {
    Endpoint endpoint = Endpoint(url: endpointUrl);
    // encode the post body as JSON and then UTF8 bytes
    var jsonStr = json.encode({
      "jsonrpc":"2.0",
      "method":"get_waypoint_view",
      "params":[],
      "id":1,
    });
    var dataBytes = utf8.encode(jsonStr);
    var client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 1);
    try {
      var request = await client.post(endpoint.url, 8080, '');
      debugPrint("No SocketException with " + endpoint.url);
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
      request.add(dataBytes);
      final response = await request.close();
      client.close();
      // turn the streamed response back to a string so that it can be parsed as JSON
      final responseBody = await response.transform(utf8.decoder).join();

      if(response.statusCode==200){
        String versionStr = "";
        endpoint.is_avail = true;
        var waypoint = rpcGetWaypointViewFromJson(responseBody).result?.waypoint ?? "0:0";
        var waypointList = waypoint.split(':');
        if(waypointList.length > 1) versionStr = waypointList[0];
        endpoint.version = int.tryParse(versionStr) ?? 0;
      }
    } on SocketException catch (_) {
      debugPrint("SocketException with " + endpoint.url);
    } on Exception catch (_) {
      debugPrint("Exception with " + endpoint.url);
    }
    client.close();
    return endpoint;
  }

  static bool timeToUpdate() {
    var now = DateTime.now();
    debugPrint("timeToUpdate - diff: ${now.difference(lastUpdate).inMinutes}");
    if (now.difference(lastUpdate).inMinutes > 15) {
      lastUpdate = now;
      return true;
    }
    return false;
  }

}