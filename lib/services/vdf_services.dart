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
    if ((account.balance < 0.01) && (account.seqNum == 0)) {
      account.proofRipperMsg = "Account is not on chain yet";
      account.mining = false;
      walletProvider.saveAccount(account);
      return;
    }
    if (account.balance < 0.01) {
      account.proofRipperMsg = "Account needs GAS";
      account.mining = false;
      walletProvider.saveAccount(account);
      return;
    }
    account.proofRipperMsg = "";
    walletProvider.saveAccount(account);
    int seqNum = account.seqNum;
    String mnem = await walletProvider.getMnemonic(account.addr);
    account.port = ReceivePort();
    debugPrint("StartingVDF");
    if (account.lastProofHash.isEmpty) {
      debugPrint("Starting Genesis Proof");
      if (account.mining) {
        account.isolate = await Isolate.spawn(doGenesisProof, [
          account.port!.sendPort,
          Account.serializeForIsolate(account, mnem)
        ]);
      }
    } else {
      debugPrint("Starting regular proof");
      if (account.mining) {
        account.isolate = await Isolate.spawn(doProof, [
          account.port!.sendPort,
          Account.serializeForIsolate(account, mnem)
        ]);
      }
    }
    if (account.mining) {
      debugPrint("Waiting");
      account.port!.listen((data) async {
        debugPrint("Isolate done");
        account.isolate?.kill(priority: Isolate.immediate);
        if (account.mining) {
          //debugPrint(data);
          var old_last_hash = account.lastProofHash;
          await LibraRpc.submitRpc(data);
          //await Future.delayed(const Duration(seconds: 60));
          // We pass all the account data in at the beginning and don't query it again,
          // we should expect it to change after ~30+ min, but this is a proof-of-conecept
          // still.
          for (int i = 0; i < 40; i++) {
            debugPrint("Waiting for tx: " + i.toString());
            await Future.delayed(const Duration(seconds: 2));
            var txStatus =
                await LibraRpc.getAccountTransaction(account.addr, seqNum);
            if ((txStatus == 0) && (account.lastProofHash != old_last_hash)) {
              debugPrint("Tx complete!");
              break;
            }
          }
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

  static Future doGenesisProof(List<dynamic> args) async {
    SendPort responsePort = args[0];
    String json = args[1];
    var list = Account.deserializeForIsolate(json);
    Account account = list[0];
    String mnem = list[1];
    String proofResult = Libra().solve_genesis_proof(
      mnem,
      account.seqNum,
    );
    Isolate.exit(responsePort, proofResult);
  }
}
