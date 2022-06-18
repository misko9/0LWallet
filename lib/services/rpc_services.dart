import 'package:Oollet/providers/wallet_provider.dart';
import 'package:async/async.dart';
import 'package:libra/models/rpc_get_account.dart';
import 'package:libra/models/rpc_get_tower_state_view.dart';
import 'package:libra/libra_rpc.dart';

import '../models/account.dart';

class RpcServices {
  static const SCALING_FACTOR = 1000000; // 1_000_000

  static fetchAllAccountInfo(WalletProvider walletProvider, Account account) async {
    FutureGroup<dynamic> futureGroup = FutureGroup<dynamic>();
    futureGroup.add(LibraRpc.getAccountRpc(account.addr));
    futureGroup.add(LibraRpc.getTowerStateViewRpc(account.addr));
    futureGroup.close();
    futureGroup.future.then((List<dynamic> list) {
      if(list.length == 2 && list[0] is RpcGetAccount) {
        RpcGetAccount getAccount = list[0] as RpcGetAccount;
        if(getAccount.result?.balances != null) {
          Balances balance = getAccount.result?.balances.firstWhere((
              element) => element.currency == "GAS",
              orElse: () => Balances(amount: -1, currency: "NULL")) ??
              Balances(amount: -1, currency: "NULL");
          if ((getAccount.result!.sequenceNumber >= account.seqNum) && (balance.amount >= 0)) {
            account.balance = balance.amount.toDouble() / SCALING_FACTOR;
            account.seqNum = getAccount.result!.sequenceNumber;
          }
        }
      }
      if(list.length == 2 && list[1] is RpcGetTowerStateView) {
        RpcGetTowerStateView getTowerStateView = list[1] as RpcGetTowerStateView;
        if((getTowerStateView.result?.verifiedTowerHeight ?? -1) >= account.towerHeight) {
          account.towerHeight = getTowerStateView.result!.verifiedTowerHeight!;
          account.epochProofs = getTowerStateView.result!.actualCountProofsInEpoch ?? 0;
        }
      }
      walletProvider.saveAccount(account);
    });
  }
}