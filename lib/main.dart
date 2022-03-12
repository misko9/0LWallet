import 'package:Oollet/ui/barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'MyTheme.dart';
import 'account_provider.dart';
import 'ui/account_list.dart';
import 'ui/app_entry.dart';
import 'ui/create_new_account.dart';
import 'ui/import_wallet.dart';
import 'ui/wallet_home.dart';

void main() => runApp(AccountProvider(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Oollet',
        initialRoute: '/',
        routes: {
          '/': (context) => const AppEntry(),
          WalletHome.route: (context) => const WalletHome(),
          CreateNewAccount.route: (context) => CreateNewAccount(),
          ImportWallet.route: (context) => ImportWallet(),
          AccountList.route: (context) => AccountList(),
          BarcodeScannerWithController.route: (context) => BarcodeScannerWithController(),
          //'/second': (context) => const SecondScreen(),
          //'/second': (context) => const SecondScreen(),
        },
        theme: MyTheme.lightTheme,
        debugShowCheckedModeBanner: false,
    );
  }
}