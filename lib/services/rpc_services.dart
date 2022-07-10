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
    RpcGetAccountState acccountState = await LibraRpc.getAccountStateRpc(account.addr);
    debugPrint("AccountState: ${acccountState.result?.blob}");
    int unlocked = Libra().get_unlocked_from_state(acccountState.result?.blob ?? "");
    debugPrint("Unlocked: $unlocked");
    int transferred = Libra().get_transferred_from_state(acccountState.result?.blob ?? "");
    debugPrint("Transferred: $transferred");
    String walletType = Libra().get_wallet_type_from_state(acccountState.result?.blob ?? "");
    debugPrint("WalletType: $walletType");
    String vouchers = Libra().get_vouchers_from_state(acccountState.result?.blob ?? "");
    debugPrint("Vouchers: $vouchers");
    String ancestry = Libra().get_ancestry_from_state(acccountState.result?.blob ?? "");
    debugPrint("Ancestry: $ancestry");
    int credits = Libra().get_make_whole_credits_from_state(acccountState.result?.blob ?? "");
    debugPrint("Credits: $credits");
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
          if (getAccount.result?.balances != null) {
            Balances balance = getAccount.result?.balances.firstWhere((
                element) => element.currency == "GAS",
                orElse: () => Balances(amount: -1, currency: "NULL")) ??
                Balances(amount: -1, currency: "NULL");
            if ((getAccount.result!.sequenceNumber >= account.seqNum) &&
                (balance.amount >= 0)) {
              account.balance = balance.amount.toDouble() / SCALING_FACTOR;
              account.seqNum = getAccount.result!.sequenceNumber;
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