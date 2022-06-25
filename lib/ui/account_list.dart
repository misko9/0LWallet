import 'package:Oollet/providers/wallet_provider.dart';
import 'package:Oollet/ui/add_watch_only_address.dart';
import 'package:Oollet/ui/app_entry.dart';
import 'package:Oollet/utils/misc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/rpc_services.dart';
import 'create_new_account.dart';
import 'import_wallet.dart';

class AccountList extends StatefulWidget {
  static const route = '/AccountList';

  const AccountList({Key? key}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("AccountList - app resumed");
      WalletProvider walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      RpcServices.fetchAllAccounts(walletProvider, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('0L Account List'),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(child: _buildAccountList(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              addNewAccount(context),
              SizedBox(width: 20),
              importAccount(context),
            ],
          )
        ]));
  }
}

Widget _buildAccountList(BuildContext context) {
  return Consumer<WalletProvider>(builder: (context, wallet, child) {
    return Card(
      child: ListView.builder(
        itemCount: wallet.accountsList.length,
        itemBuilder: (context, index) {
          var account = wallet.accountsList[index];
          return Dismissible(
              key: Key(account.addr),
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                color: Colors.red,
                alignment: Alignment.centerLeft,
                child: const Icon(Icons.delete_forever),
              ),
              secondaryBackground: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete_forever),
              ),
              child: Card(
                color: Color(0xE3FFFFFF),
                child: Column(children: [
                  ListTile(
                    leading: account.watchOnly
                        ? Icon(Icons.remove_red_eye_outlined)
                        : Icon(Icons.account_balance_wallet_outlined),
                    title: Text(account.name),
                    subtitle: Text(account.addr.toLowerCase()),
                    onTap: () {
                      wallet.setNewSelectedAccount(account.addr);
                      RpcServices.fetchAccountInfo(wallet, account, false);
                      Navigator.pop(context);
                    },
                    trailing: const Icon(Icons.more_vert),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          "Tower: ",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.end,
                        )),
                        Expanded(
                            child: Text(
                          "${intFormatUS(account.towerHeight)} [${account.epochProofs}]",
                          textAlign: TextAlign.end,
                        )),
                        Expanded(
                            child: Text(
                          "Balance: ",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.end,
                        )),
                        Expanded(
                            child: Text(
                          account.balance >= 1000000.0 ? intFormatUS(account.balance.floor())
                              : doubleFormatUS(account.balance),
                          textAlign: TextAlign.end,
                        )),
                      ],
                    ),
                  ),
                ]),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text(
                          "Are you sure you wish to remove this account?"),
                      actions: <Widget>[
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text("Yes/Delete")),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel"),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) async {
                wallet.deleteAccount(account);
                if (wallet.accountsList.isEmpty) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      AccountList.route, ModalRoute.withName(AppEntry.route));
                }
              });
        },
      ),
    );
  });
}

Widget addNewAccount(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      Navigator.of(context).pushNamed(CreateNewAccount.route);
    },
    child: Text('Create Account'),
  );
}

Widget importAccount(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      //Navigator.of(context).pushNamed(ImportWallet.route);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_red_eye_outlined),
                          Text(
                            " Watch-only address",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(AddWatchOnlyAddress.route);
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined),
                          Text(
                            " From mnemonic",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(ImportWallet.route);
                    },
                  ),
                ],
              ),
            );
          });
    },
    child: Text('Import Account'),
  );
}
