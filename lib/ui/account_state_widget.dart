import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:libra/libra_rpc.dart';
import 'package:libra/libra.dart';

import '../models/account.dart';
import '../providers/wallet_provider.dart';
import '../services/rpc_services.dart';
import '../utils/misc.dart';

class AccountStateWidget extends StatefulWidget {
  const AccountStateWidget({
    Key? key,
    required this.account,
  }) : super(key: key);
  final Account account;

  @override
  State<AccountStateWidget> createState() => _AccountStateWidgetState();
}

class _AccountStateWidgetState extends State<AccountStateWidget> {
  bool _claimMakeWholeEnabled = true;

  @override
  Widget build(BuildContext context) {
    String walletType = widget.account.walletType;
    return walletType != "normal"
        ? SafeArea(
      maintainBottomViewPadding: true,
      child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: Colors.blueGrey[50],
              //color: const Color(0xFFF5F5F5),
              elevation: 1,
              margin: EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "Account State",
                      style: TextStyle(
                        fontSize: 18,
                        //fontWeight: FontWeight.bold,
                        //decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Divider(height: 0, thickness: 3, indent: 10, endIndent: 10,),
                  SizedBox(height: 8,),
                  _accountStateContents(widget.account),
                ],
              ),
            ),
        )
        : Container();
  }

  _accountStateContents(Account account) {
    switch (account.walletType) {
      case "Normal":
        return normalWalletAccountState(account);
      case "Slow":
        return slowWalletAccountState(account);
      case "Community":
        return communityWalletAccountState(account);
      default:
        return normalWalletAccountState(account);
    }
  }

  _walletType(Account account) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          const Expanded(
              child: Text(
            "Wallet Type: ",
            textAlign: TextAlign.end,
          )),
          Expanded(
              child: Text(
            account.isValidator
                ? "Validator/${account.walletType}"
                : account.isOperator
                    ? "Operator/${account.walletType}"
                    : account.walletType,
            textAlign: TextAlign.end,
          )),
          const SizedBox(
            width: 50,
          ),
        ],
      ),
    );
  }

  _makeWhole(Account account) {
    return ((account.makeWhole > 0.00001) && !(account.makeWholeClaimed))
        ? Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Expanded(
                    child: Text(
                  "Make whole credits: ",
                  textAlign: TextAlign.end,
                )),
                Expanded(
                    child: Text(
                  doubleFormatUS(account.makeWhole),
                  textAlign: TextAlign.end,
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 3.0),
                  child: SizedBox(
                    width: 40.0,
                    height: 14.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(0.0),
                      ),
                      onPressed: () => _claimMakeWholeEnabled
                          ? _confirmClaimMakeWhole(account)
                          : null,
                      child: const Text(
                        "Claim",
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ),
                  ),
                ),
                //SizedBox(width: 40,),
              ],
            ),
          )
        : Container();
  }

  _watchOnlyDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Watch-only account"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                setState(() => _claimMakeWholeEnabled = true);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _confirmClaimMakeWhole(Account account) {
    setState(() => _claimMakeWholeEnabled = false);
    // set up the button
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        setState(() => _claimMakeWholeEnabled = true);
        Navigator.of(context).pop();
      },
    );

    // set up the button
    Widget okButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        _sendMakeWholeTransaction(account);
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      scrollable: true,
      title: const Text("Confirm"),
      content: const Text(
        'Claim Make Whole',
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    account.watchOnly
        ? _watchOnlyDialog()
        : showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return alert;
            },
          );
  }

  _sendMakeWholeTransaction(Account account) async {
    WalletProvider walletProvider =
        Provider.of<WalletProvider>(context, listen: false);
    await RpcServices.fetchAccountInfo(walletProvider, account, false);
    int seqNum = account.seqNum;
    String mnem = await walletProvider.getMnemonic(account.addr);
    var signedTx = Libra.claim_make_whole(mnem, seqNum);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 18),
      content: Row(
        children: const <Widget>[
          CircularProgressIndicator(),
          Text("   Sending...")
        ],
      ),
    ));
    var submitStatus = await LibraRpc.submitRpc(signedTx);
    debugPrint("Submit status: " + submitStatus.toString());
    var statusString = "Timed-out";
    if (submitStatus == -99999) {
      statusString = "Failure - can't connect";
      _sendButtonDialogTemp(statusString, account);
    } else {
      for (int i = 0; i < 20; i++) {
        debugPrint("Waiting for tx: " + i.toString());
        await Future.delayed(const Duration(seconds: 1));
        var txStatus =
            await LibraRpc.getAccountTransaction(account.addr, seqNum);
        if (txStatus == 0) {
          debugPrint("Tx complete!");
          statusString = "Success";
          break;
        } else if (txStatus == -127) {
          debugPrint("Tx completed with move_abort");
          statusString = "Failed, move abort";
          break;
        } else if (txStatus == -128) {
          debugPrint("Tx completed with move_abort & null");
          statusString = "Failed, is account on-chain?";
          break;
        }
      }
      _sendButtonDialogTemp(statusString, account);
    }
  }

  _sendButtonDialogTemp(String status, Account account) {
    ScaffoldMessenger.of(context).clearSnackBars();
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        WalletProvider walletProvider =
            Provider.of<WalletProvider>(context, listen: false);
        RpcServices.fetchAccountInfo(walletProvider, account, false);
        RpcServices.fetchAccountState(walletProvider, account).then((_) {
          setState(() => _claimMakeWholeEnabled = true);
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Make Whole Tx Complete"),
      content: Text(status),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _unlocked(double unlocked) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          const Expanded(
              child: Text(
            "Unlocked: ",
            textAlign: TextAlign.end,
          )),
          Expanded(
              child: Text(
            doubleFormatUS(unlocked),
            textAlign: TextAlign.end,
          )),
          const SizedBox(
            width: 50,
          ),
        ],
      ),
    );
  }

  _transferred(double transferred) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Transferred: ",
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
              child: Text(
            doubleFormatUS(transferred),
            textAlign: TextAlign.end,
          )),
          const SizedBox(
            width: 50,
          ),
        ],
      ),
    );
  }

  _ancestry(String ancestry) {
    List<String> ancestryList = ancestry.split(',');
    if (ancestryList.last.isEmpty) {
      ancestryList.removeLast();
    }
    int generation = ancestryList.length;
    if (ancestryList.isEmpty) {
      ancestryList.add('Genesis');
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        //mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Ancestry (Gen $generation)",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: ancestryList.length,
              itemBuilder: (context, index) {
                return Text(
                  ancestryList[index],
                  textAlign: TextAlign.end,
                  style:
                      const TextStyle(fontSize: 13, fontFamily: 'RobotoMono'),
                );
              }),
        ],
      ),
    );
  }

  _vouchers(String vouchers) {
    List<String> voucherList = vouchers.split(',');
    if (voucherList.last.isEmpty) {
      voucherList.removeLast();
    }
    int voucherSize = voucherList.length;
    if (voucherList.isEmpty) {
      voucherList.add('None');
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Vouchers ($voucherSize)",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: voucherList.length,
              itemBuilder: (context, index) {
                return Text(
                  voucherList[index],
                  textAlign: TextAlign.end,
                  style:
                      const TextStyle(fontSize: 13, fontFamily: 'RobotoMono'),
                );
              }),
        ],
      ),
    );
  }

// 		1. Allow claim make whole, if > 0
// 	2. Is there anything to show for operator?
  normalWalletAccountState(Account account) {
    double makeWhole = account.makeWhole;
    return Column(
      children: [
        _walletType(account),
        _makeWhole(account),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

// 	1. Allow claim make whole, if > 0
// 4. Check if Validator
// 	1. Get vouchers
// 	2. Get IP of validator/fullnode
// 	3. Proofs in epoch red/green
// 		1. Get web monitor and show:
// 			1. If web monitor is available
// 			2. If port 6180 is open on val
// 			3. If fullnode is accessible and up-to-date (Show RMS?)
// 			4. 5% of votes?
  slowWalletAccountState(Account account) {
    return Column(
      children: [
        _walletType(account),
        _makeWhole(account),
        _unlocked(account.unlocked),
        _transferred(account.transferred),
        account.isValidator ? _ancestry(account.ancestry) : Container(),
        account.isValidator ? _vouchers(account.vouchers) : Container(),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

// Check if frozen, or other delays on transfers, or transfers in general
  communityWalletAccountState(Account account) {
    return Column(
      children: [
        _walletType(account),
        //_isFrozen(),
        //_consecutiveRejections(),
        //_unfreeze_votes(),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
