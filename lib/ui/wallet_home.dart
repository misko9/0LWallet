import 'package:Oollet/providers/wallet_provider.dart';
import 'package:Oollet/services/rpc_services.dart';
import 'package:Oollet/ui/qr_code_dialog.dart';
import 'package:Oollet/ui/send_transaction.dart';
import 'package:Oollet/ui/settings.dart';
import 'package:flutter/material.dart';
import 'package:libra/libra.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'account_list.dart';

class WalletHome extends StatefulWidget {
  const WalletHome({Key? key}) : super(key: key);
  static const route = '/WalletHome';

  @override
  WalletHomeState createState() => WalletHomeState();
}

class WalletHomeState extends State<WalletHome> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final libra = Libra();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
      WalletProvider walletProvider = Provider.of<WalletProvider>(context, listen: false);
      RpcServices.fetchAllAccountInfo(walletProvider, walletProvider.selectedAccount);
    }
  }

  // TODO detect no nodes...
/* else if (balance == -1.0) { // Failure to connect to a node
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text("Cannot connect to node(s)",)
              ],),));}}
*/
  _navigateAndSendTx(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SendTransaction()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountList()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Hero(
            tag: 'appsettings',
            child: Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 24,
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppSettings()),
          ),
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
            header: const WaterDropHeader(),
            onRefresh: () async {
              WalletProvider walletProvider = Provider.of<WalletProvider>(context, listen: false);
              await RpcServices.fetchAllAccountInfo(walletProvider, walletProvider.selectedAccount);
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
                      key: const Key('my-widget-key'),
                      onVisibilityChanged: (visibilityInfo) {
                        var visiblePercentage =
                            visibilityInfo.visibleFraction * 100;
                        debugPrint(
                            'Widget ${visibilityInfo.key} is $visiblePercentage% visible');
                        if (visiblePercentage > 80) {
                          WalletProvider walletProvider = Provider.of<WalletProvider>(context, listen: false);
                          RpcServices.fetchAllAccountInfo(walletProvider, walletProvider.selectedAccount);
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
                              child: Consumer<WalletProvider>(
                                  builder: (context, wallet, child) {
                                return Text(wallet.selectedAccount.name);
                              }),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 5, 5, 5),
                              child: Consumer<WalletProvider>(
                                  builder: (context, wallet, child) {
                                return Text(wallet.selectedAccount.addr);
                              }),
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
                                Consumer<WalletProvider>(
                                    builder: (context, wallet, child) {
                                  return Text(
                                    wallet.selectedAccount.balance.toStringAsFixed(2),
                                    textAlign: TextAlign.center,
                                  );
                                }),
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
                                      child: Consumer<WalletProvider>(
                                          builder: (context, wallet, child) {
                                            return Text(wallet.selectedAccount.towerHeight.toString(),
                                            textAlign: TextAlign.center,);
                                          }),
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
                                  child: Consumer<WalletProvider>(
                                      builder: (context, wallet, child) {
                                        return Text(wallet.selectedAccount.walletType);
                                      }),
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
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return QrCodeDialog(addr: Provider.of<WalletProvider>(context, listen: false).selectedAccount.addr);
                                        }
                                    )
                                  ),
                                  ElevatedButton(
                                    child: const Text(' Send '),
                                    onPressed: () =>
                                        _navigateAndSendTx(context),
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
