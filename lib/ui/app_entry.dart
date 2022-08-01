import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import 'account_list.dart';
import 'wallet_home.dart';

/// Splash
/// Default page route that determines if user is logged in and routes them appropriately.
class AppEntry extends StatefulWidget {
  const AppEntry({Key? key}) : super(key: key);
  static const route = '/AppEntry';

  @override
  AppEntryState createState() => AppEntryState();
}

class AppEntryState extends State<AppEntry> {

  Future<void> _getAccountList() async {
    //await Future.delayed(const Duration(seconds: 1));
    var wallet = Provider.of<WalletProvider>(context, listen: false);
    var numOfAccounts = await wallet.getAccountListSizeAndInit();
    if(numOfAccounts == 0) {
      Navigator.of(context).pushReplacementNamed(AccountList.route);
      //Navigator.of(context).pushReplacementNamed(NewUser.route);
    } else {
      Navigator.of(context).pushReplacementNamed(WalletHome.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    _getAccountList();
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Image.asset('icons/ol_logo_whitebg_circle/res/mipmap-xxhdpi/ic_launcher.png')
          )
      )
    );
  }
}
