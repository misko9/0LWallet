import 'package:Oollet/ui/send_transaction.dart';
import 'package:flutter/material.dart';
import 'package:libra/libra.dart';
import 'package:libra/libra_rpc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../account_provider.dart';
import '../main.dart';
import '../models/account.dart';
import 'account_list.dart';
import 'dart:async';

class WalletHome extends StatefulWidget {
  const WalletHome({Key? key}) : super(key: key);
  static const route = '/WalletHome';

  @override
  WalletHomeState createState() => WalletHomeState();
}

class WalletHomeState extends State<WalletHome> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Account selectedAccount;
  final libra = Libra();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshScreen();
    }
  }

  _getBalance() async {
    var selectedAccount = AccountProvider.of(context).selectedAccount;
    double balance = await LibraRpc.getAccountBalance(selectedAccount.addr);
    if (balance >= 0) {
      setState(() {
        selectedAccount.balance = balance;
        AccountProvider.of(context).saveAccount(selectedAccount);
      });
    }
  }

  _getTowerHeight() async {
    var selectedAccount = AccountProvider.of(context).selectedAccount;
    var towerHeight = await LibraRpc.getTowerHeight(selectedAccount.addr);
    if (towerHeight >= 0) {
      setState(() {
        selectedAccount.towerHeight = towerHeight;
        AccountProvider.of(context).saveAccount(selectedAccount);
      });
    }
  }

  _refreshScreen() {
    debugPrint("_refreshScreen()");
    _getBalance();
    _getTowerHeight();
  }

  _navigateAndGetAccount(BuildContext context) async {
    String addr = "";
    addr = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountList()),
    );
    setState(() {
      if(addr != null && addr != "") {
        AccountProvider.of(context).setNewSelectedAccount(addr);
      }
    });
  }

  _navigateAndSendTx(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SendTransaction()),
    );
  }

  _displayQrCode(BuildContext context, String addr) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
        _refreshScreen();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Scan QR code"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              addr,
              style: TextStyle(fontSize: 12),
            ),
            Container(
              height: 160,
              width: 160,
              constraints: const BoxConstraints(maxWidth: 160, maxHeight: 160),
              child: QrImage(
                data: addr,
                version: QrVersions.auto,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                size: 160,
                gapless: true,
                embeddedImage:
                    AssetImage('icons/ol_logo_whitebg_square/1024.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    selectedAccount = AccountProvider.of(context).selectedAccount;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('0L Wallet'),
        actions: [
          IconButton(
            icon: const Icon(
              //Image.asset('icons/ic_mycoinwallet4.xml'),
              Icons.account_balance_wallet,
              color: Colors.white,
            ),
            onPressed: () {
              _navigateAndGetAccount(context);
            },
          ),
        ],
        automaticallyImplyLeading: false,
        leading: const Icon(
          Icons.settings_outlined,
          color: Colors.black,
          size: 24,
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        //minimum: const EdgeInsets.only(bottom: 5.0),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SmartRefresher(
            controller: _refreshController,
            enablePullUp: false,
            header: WaterDropHeader(),
            onRefresh: () async {
              _getTowerHeight();
              await _getBalance();
              _refreshController.refreshCompleted();
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0, 0),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                    child: VisibilityDetector(
                      key: Key('my-widget-key'),
                      onVisibilityChanged: (visibilityInfo) {
                        var visiblePercentage =
                            visibilityInfo.visibleFraction * 100;
                        debugPrint(
                            'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');
                        if(visiblePercentage > 80) {
                          _refreshScreen();
                        }
                      },
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: const Color(0xFFF5F5F5),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 20, 20, 0),
                              child: Text(selectedAccount.name),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 5, 5, 5),
                              child: Text(selectedAccount.addr),
                            ),
                            const Divider(
                              height: 10,
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'Balance:',
                                ),
                                Text(
                                  selectedAccount.balance.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const Divider(
                              height: 10,
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                            ),
                            const Text(
                              'Tower Height',
                            ),
                            Stack(
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(0, 0),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF660505),
                                      ),
                                    ),
                                    child: Align(
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        selectedAccount.towerHeight.toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 5, 0),
                                  child: Text(
                                    'Wallet type:',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      5, 0, 0, 0),
                                  child: Text(
                                    selectedAccount.walletType,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10, 10, 10, 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    child: const Text('Receive'),
                                    onPressed: () => _displayQrCode(
                                        context, selectedAccount.addr),
                                  ),
                                  ElevatedButton(
                                    child: const Text(' Send '),
                                    onPressed: () => _navigateAndSendTx(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget startDrawer(BuildContext context) {
  return Drawer(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('This is the Drawer1'),
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close Drawer1'),
          ),
        ],
      ),
    ),
  );
}
