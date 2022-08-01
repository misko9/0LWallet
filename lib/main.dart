import 'package:Oollet/ui/add_watch_only_address.dart';
import 'package:Oollet/ui/barcode_scanner.dart';
import 'package:Oollet/ui/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:libra/endpoints.dart';
import 'MyTheme.dart';
import 'providers/wallet_provider.dart';
import 'ui/account_list.dart';
import 'ui/app_entry.dart';
import 'ui/create_new_account.dart';
import 'ui/import_wallet.dart';
import 'ui/wallet_home.dart';
import 'utils/hive_cache.dart';

void main() => initSettings().then((_) {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WalletProvider(),
      child: MyApp(),
    )
  );
});

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: HiveCache(),
  );
  Endpoints.testnetEnabled = false; //Settings.getValue<bool>(AppSettings.keyTestnetSwitch) ?? false;
  Endpoints.overridePeers = Settings.getValue<String>(AppSettings.keyOverridePeers) ?? '';
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
          AddWatchOnlyAddress.route: (context) => AddWatchOnlyAddress(),
          AccountList.route: (context) => const AccountList(),
          AppSettings.route: (context) => AppSettings(),
          BarcodeScannerWithController.route: (context) => const BarcodeScannerWithController(),
        },
        theme: MyTheme.lightTheme,
        debugShowCheckedModeBanner: false,
    );
  }
}