import 'package:Oollet/providers/wallet_provider.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:libra/models/rpc_get_account.dart';
import 'package:libra/models/rpc_get_account_state.dart';
import 'package:libra/models/rpc_get_tower_state_view.dart';
import 'package:libra/libra_rpc.dart';
import 'package:libra/libra.dart';

import '../models/account.dart';

class RpcServices {
  static const SCALING_FACTOR = 1000000; // 1_000_000

  static Future fetchAccountState(WalletProvider walletProvider, Account account, bool rateLimit) async {
    RpcGetAccountState accountState = await LibraRpc.getAccountStateRpc(account.addr);
    debugPrint("AccountState: ${accountState.result?.blob}");
    if((accountState.result?.blob != null) && ((accountState.result?.blob ?? "").isNotEmpty)) {
      String walletType = Libra().get_wallet_type_from_state(accountState.result?.blob ?? "");
      if(account.walletType == "normal") {
        account.walletType = walletType;
      } else if (account.walletType == "Normal") {
        account.walletType = walletType;
      } else if ((walletType == "Slow") || (walletType == "Community")) {
        account.walletType = walletType;
      }
      switch (walletType) {
        case "Normal":
          int credits = Libra().get_make_whole_credits_from_state(
              accountState.result?.blob ?? "");
          if(credits > 0) {
            account.makeWhole = credits.toDouble() / SCALING_FACTOR;
          }
          break;
        case "Slow":
          int unlocked = Libra().get_unlocked_from_state(
              accountState.result?.blob ?? "");
          if(unlocked > 0) {
            account.unlocked = unlocked.toDouble() / SCALING_FACTOR;
          }
          int transferred = Libra().get_transferred_from_state(
              accountState.result?.blob ?? "");
          if(transferred > 0) {
            account.transferred = transferred.toDouble() / SCALING_FACTOR;
          }
          bool isValidator = Libra().is_validator_from_state(accountState.result?.blob ?? "");
          if (isValidator) {
            account.isValidator = isValidator;
            String vouchers = Libra().get_vouchers_from_state(accountState.result?.blob ?? "");
            if(vouchers.isNotEmpty) {
              account.vouchers = vouchers;
            }
            String ancestry = Libra().get_ancestry_from_state(accountState.result?.blob ?? "");
            debugPrint("ancestry = $ancestry");
            if(ancestry.isNotEmpty) {
              account.ancestry = ancestry;
            }
            //debugPrint("Ancestry: $ancestry");
          } else {
            int credits = Libra().get_make_whole_credits_from_state(
                accountState.result?.blob ?? "");
            if(credits > 0) {
              account.makeWhole = credits.toDouble() / SCALING_FACTOR;
            }
          }
          break;
        case "Community":
          break;
        default:
          break;
      }
      walletProvider.saveAccount(account);
    }
  }

  static Future<int> fetchAccountInfo(WalletProvider walletProvider, Account account, bool rateLimit) async {
    int result = 0;
    var now = DateTime.now();
    if (!rateLimit || now
        .difference(account.lastUpdated)
        .inMinutes > 5) {
      account.lastUpdated = now;
      FutureGroup<dynamic> futureGroup = FutureGroup<dynamic>();
      futureGroup.add(LibraRpc.getAccountRpc(account.addr));
      futureGroup.add(LibraRpc.getTowerStateViewRpc(account.addr));
      futureGroup.close();
      await futureGroup.future.then((List<dynamic> list) {
        debugPrint("fetchAccountInfo list size: ${list.length}");
        if (list.length == 2 && list[0] is RpcGetAccount) {
          RpcGetAccount getAccount = list[0] as RpcGetAccount;
          debugPrint("In RpcGetAccount");
          if (getAccount.result?.balances != null) {
            debugPrint("balance != null");
            Balances balance = getAccount.result?.balances.firstWhere((
                element) => element.currency == "GAS",
                orElse: () => Balances(amount: -1, currency: "NULL")) ??
                Balances(amount: -1, currency: "NULL");
            if ((getAccount.result!.sequenceNumber >= account.seqNum) &&
                (balance.amount >= 0)) {
              debugPrint("Seq # >= current, balance >= 0");
              account.balance = balance.amount.toDouble() / SCALING_FACTOR;
              account.seqNum = getAccount.result!.sequenceNumber;
              if(!rateLimit) {
                debugPrint("!rateLimite");
                fetchAccountState(walletProvider, account, rateLimit);
              }
              //account.walletType = getAccount.result!.role!.type;
            }
          }
        } else { // Failure with node
          debugPrint("Cannot connect to nodes");
          result = -1;
        }
        if (list.length == 2 && list[1] is RpcGetTowerStateView) {
          RpcGetTowerStateView getTowerStateView = list[1] as RpcGetTowerStateView;
          if ((getTowerStateView.result?.verifiedTowerHeight ?? -1) >=
              account.towerHeight) {
            account.towerHeight =
            getTowerStateView.result!.verifiedTowerHeight!;
            account.epochProofs =
                getTowerStateView.result!.actualCountProofsInEpoch ?? 0;
            account.lastEpochMined = getTowerStateView.result!.latestEpochMining ?? account.lastEpochMined;
          }
        } else {
          result = -1;
        }
        walletProvider.saveAccount(account);
      });
    }
    return result;
  }

  static fetchAllAccounts(WalletProvider walletProvider, bool rateLimit) async {
    for (var element in walletProvider.accountsList) {
      await fetchAccountInfo(walletProvider, element, rateLimit);
    }
  }
}