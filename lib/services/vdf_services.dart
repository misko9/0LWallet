import 'dart:isolate';

import 'package:Oollet/providers/wallet_provider.dart';
import 'package:Oollet/services/rpc_services.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:libra/libra_rpc.dart';
import 'package:libra/libra.dart';

import '../models/account.dart';

class VdfServices {
  static Future startProofRipper(
      WalletProvider walletProvider, Account account) async {
    debugPrint("StartProofRipper");
    int result =
        await RpcServices.fetchAccountInfo(walletProvider, account, false);
    if (result < 0) {
      account.proofRipperMsg = "Cannot connect to node";
      account.mining = false;
      walletProvider.saveAccount(account);
      return;
    }
    if (account.lastProofHash.isEmpty) {
      account.proofRipperMsg = "No preimage found";
      account.mining = false;
      walletProvider.saveAccount(account);
      return;
    }
    account.proofRipperMsg = "";
    walletProvider.saveAccount(account);
    String mnem = await walletProvider.getMnemonic(account.addr);
    account.port = ReceivePort();
    debugPrint("StartingVDF");
    if (account.mining) {
      account.isolate = await Isolate.spawn(
          doProof, [account.port!.sendPort, Account.serializeForIsolate(account, mnem)]);
      debugPrint("Waiting");
      account.port!.listen((data) async {
        debugPrint("Isolate done");
        account.isolate?.kill(priority: Isolate.immediate);
        if (account.mining) {
          await LibraRpc.submitRpc(data);
          await Future.delayed(const Duration(seconds: 60));
          startProofRipper(walletProvider, account);
        }
      });
    }
  }

  // Once critical computation is met, doProof won't listen to a kill command
  /*static Future spawnSecondLevelIsolate(List<dynamic> args) async {
    SendPort responsePort = args[0];
    String json = args[1];
    final port = ReceivePort();
    await Isolate.spawn(
        doProof, [port.sendPort, json]);
    port.listen((message) async {
      Isolate.exit(responsePort, message);
    });
  }*/

  // Temporary test function, not for production
  static Future doProof(List<dynamic> args) async {
    SendPort responsePort = args[0];
    String json = args[1];
    var list = Account.deserializeForIsolate(json);
    Account account = list[0];
    String mnem = list[1];
    String proofResult = Libra().solve_proof(
      account.lastProofHash,
      mnem,
      account.seqNum,
      account.towerHeight + 1,
    );
    Isolate.exit(responsePort, proofResult);
  }
}
