import 'package:Oollet/ui/barcode_scanner.dart';
import 'package:Oollet/ui/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:libra/libra_rpc.dart';
import 'MyTheme.dart';
import 'account_provider.dart';
import 'ui/account_list.dart';
import 'ui/app_entry.dart';
import 'ui/create_new_account.dart';
import 'ui/import_wallet.dart';
import 'ui/wallet_home.dart';
import 'utils/hive_cache.dart';

void main() => initSettings().then((_) {
  runApp(AccountProvider(child: MyApp()));
});

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: HiveCache(),
  );
  LibraRpc.testnetEnabled = Settings.getValue<bool>(AppSettings.keyTestnetSwitch) ?? false;
  LibraRpc.overridePeers = Settings.getValue<String>(AppSettings.keyOverridePeers) ?? '';
}

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
          AccountList.route: (context) => const AccountList(),
          AppSettings.route: (context) => AppSettings(),
          BarcodeScannerWithController.route: (context) => const BarcodeScannerWithController(),
        },
        theme: MyTheme.lightTheme,
        debugShowCheckedModeBanner: false,
    );
  }
}