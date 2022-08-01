import 'package:Oollet/providers/wallet_provider.dart';
import 'package:Oollet/ui/add_watch_only_address.dart';
import 'package:Oollet/ui/app_entry.dart';
import 'package:Oollet/ui/common/name_input_field.dart';
import 'package:Oollet/utils/misc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late TextEditingController nameController1;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    nameController1 = TextEditingController();
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
          Expanded(child: _buildAccountList(context, nameController1, formKey, setState)),
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

Widget _buildAccountList(BuildContext context, TextEditingController nameController1, GlobalKey<FormState> formKey, Function(Function()) setState) {
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
                color: Color(0xECFFFFFF),
                child: Column(children: [
                  ListTile(
                    leading: account.watchOnly
                        ? Icon(Icons.remove_red_eye_outlined)
                        : Icon(Icons.account_balance_wallet_outlined),
                    title: Text(account.name),
                    subtitle: Text(account.addr.toLowerCase()),
                    onTap: () {
                      wallet.setNewSelectedAccount(account.addr); // don't change addr case
                      RpcServices.fetchAccountInfo(wallet, account, false);
                      RpcServices.fetchAccountState(wallet, account);
                      Navigator.pop(context);
                    },
                    trailing: PopupMenuButton<int>(
                      // Callback that sets the selected popup menu item.
                        onSelected: (int item) async {
                          switch(item) {
                            case 1:
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      titlePadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                                      title: Text('Change account name'),
                                      contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(account.name),
                                          Text(account.addr.toLowerCase(), style: TextStyle(fontSize: 12),),
                                          SizedBox(height: 4,),
                                          Form(
                                              key: formKey,
                                              child: NameInputField(nameController1: nameController1,),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          child: Text('CANCEL'),
                                          onPressed: () {
                                            nameController1.clear();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ElevatedButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            final form = formKey.currentState;
                                            bool? valid = form?.validate();
                                            if (valid != null && valid ==
                                                true) { // Validation passes
                                              account.name = nameController1.value
                                                  .text;
                                              nameController1.clear();
                                              Provider.of<WalletProvider>(
                                                  context, listen: false)
                                                  .saveAccount(account);
                                              Navigator.pop(context);
                                              // Save new account and open it
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  });
                              break;
                            case 2:
                              debugPrint("Copy address");
                              Clipboard.setData(ClipboardData(text: account.addr)).then((_){
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                    SnackBar(
                                        content: Text('Copied address to your clipboard'),
                                        backgroundColor: Colors.black.withOpacity(0.8),
                                    )
                                );
                              });
                              break;
                            case 3:
                              Uri explorerUri =
                                Uri(scheme: 'https', host: '0l.interblockcha.in', path: 'address/${account.addr}');
                                launchUrl(explorerUri, mode: LaunchMode.externalApplication,);
                              break;
                            default:
                              debugPrint("Default popup menu button");
                              break;
                          }
                        },
                        icon: const Icon(Icons.more_vert, color: Colors.black54,),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Text('Rename account'),
                          ),
                          const PopupMenuItem<int>(
                            value: 2,
                            child: Text('Copy address'),
                          ),
                          const PopupMenuItem<int>(
                            value: 3,
                            child: Text('View in explorer'),
                          ),
                        ]),
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
                              : doubleFormatUS(account.balance >= .005 ? account.balance - .004999 : account.balance), // Fix rounding up
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
