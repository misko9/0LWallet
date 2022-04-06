import 'package:Oollet/ui/app_entry.dart';
import 'package:flutter/material.dart';

import '../account_provider.dart';
import 'create_new_account.dart';
import 'import_wallet.dart';

class AccountList extends StatefulWidget {
  static const route = '/AccountList';

  const AccountList({Key? key}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
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
  var accountList = AccountProvider.of(context).cachedAccounts;
  return Card(
    child: ListView.builder(
      itemCount: accountList.length,
      itemBuilder: (context, index) {
        var account = accountList[index];
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
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(account.name),
                subtitle: Text(account.addr),
                onTap: () {
                  Navigator.pop(context, account.addr);
                },
                trailing: const Icon(Icons.more_vert),
              ),
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
              AccountProvider.of(context).deleteAccount(accountList[index]);
              if(AccountProvider.of(context).cachedAccounts.isEmpty) {
                Navigator.of(context).pushNamedAndRemoveUntil(AccountList.route, ModalRoute.withName(AppEntry.route));
              }
            });
      },
    ),
  );
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
      Navigator.of(context).pushNamed(ImportWallet.route);
    },
    child: Text('Import Account'),
  );
}
