import 'package:Oollet/providers/wallet_provider.dart';
import 'package:Oollet/services/rpc_services.dart';
import 'package:Oollet/ui/qr_code_dialog.dart';
import 'package:Oollet/ui/send_transaction.dart';
import 'package:Oollet/ui/settings.dart';
import 'package:Oollet/utils/misc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libra/libra.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
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
      debugPrint("WalletStateHome app resumed");
      WalletProvider walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      RpcServices.fetchAccountInfo(
              walletProvider, walletProvider.selectedAccount, true)
          .then((int result) {
        // Displays only for app resume, pull-to-refresh, & visibility detector > 80%
        if (result < 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 5),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  "Cannot connect to node(s)",
                )
              ],
            ),
          ));
        }
      });
    }
  }

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
      resizeToAvoidBottomInset: false,
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
              WalletProvider walletProvider =
                  Provider.of<WalletProvider>(context, listen: false);
              RpcServices.fetchAllAccounts(walletProvider, true);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountList()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: Colors.grey,
            size: 24,
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
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SmartRefresher(
            controller: _refreshController,
            enablePullUp: false,
            header: const WaterDropHeader(),
            onRefresh: () async {
              WalletProvider walletProvider =
                  Provider.of<WalletProvider>(context, listen: false);
              int result = await RpcServices.fetchAccountInfo(
                  walletProvider, walletProvider.selectedAccount, false);
              await RpcServices.fetchAccountState(walletProvider, walletProvider.selectedAccount, false);
              // Displays only for app resume, pull-to-refresh, & visibility detector > 80%
              if (result < 0) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 5),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "Cannot connect to node(s)",
                      )
                    ],
                  ),
                ));
              }
              _refreshController.refreshCompleted();
            },
            child: SingleChildScrollView(
              child: Column(
                //mainAxisSize: MainAxisSize.max,
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
                            WalletProvider walletProvider =
                                Provider.of<WalletProvider>(context,
                                    listen: false);
                            RpcServices.fetchAccountInfo(walletProvider,
                                    walletProvider.selectedAccount, true)
                                .then((int result) {
                              // Displays only for app resume, pull-to-refresh, & visibility detector > 80%
                              if (result < 0) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  duration: const Duration(seconds: 5),
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const <Widget>[
                                      Text(
                                        "Cannot connect to node(s)",
                                      )
                                    ],
                                  ),
                                ));
                              }
                            });
                          }
                        },
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          color: const Color(0xFFF5F5F5),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Consumer<WalletProvider>(
                                  builder: (context, wallet, child) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(children: [
                                    Row(children: [
                                      wallet.selectedAccount.watchOnly
                                          ? Icon(Icons.remove_red_eye_outlined)
                                          : Icon(Icons
                                              .account_balance_wallet_outlined),
                                    ]),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.70,
                                          child: Center(
                                            child: Text(
                                              wallet.selectedAccount.name,
                                              style: TextStyle(fontSize: 18.0),
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]),
                                );
                              }),
                              Consumer<WalletProvider>(
                                  builder: (context, wallet, child) {
                                String accountAddr =
                                    wallet.selectedAccount.addr.toLowerCase();
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.link,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        Uri explorerUri = Uri(
                                            scheme: 'https',
                                            host: '0l.interblockcha.in',
                                            path: 'address/$accountAddr');
                                        launchUrl(
                                          explorerUri,
                                          //mode: LaunchMode.inAppWebView,
                                          //webViewConfiguration: const WebViewConfiguration(
                                          //    headers: <String, String>{'my_header_key': 'my_header_value'}),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                    ),
                                    Text(accountAddr),
                                    IconButton(
                                      constraints: BoxConstraints(),
                                      icon: const Icon(
                                        Icons.copy,
                                        color: Colors.black,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(
                                                ClipboardData(text: accountAddr))
                                            .then((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: const Text(
                                                'Copied address to your clipboard'),
                                            backgroundColor:
                                                Colors.black.withOpacity(0.8),
                                          ));
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }),
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
                                      doubleFormatUS( wallet.selectedAccount.balance >= .005 ?
                                          wallet.selectedAccount.balance -.004999 : wallet.selectedAccount.balance), // Fix rounding up
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
                              const Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 4),
                                child: Text(
                                  'Tower Height',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
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
                                          return Text(
                                            intFormatUS(wallet
                                                .selectedAccount.towerHeight),
                                            textAlign: TextAlign.center,
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              /*Row(
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
                                      return Text(
                                          wallet.selectedAccount.walletType);
                                    }),
                                  ),
                                ],
                              ),*/
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 5, 0),
                                    child: Text(
                                      'Proofs in Epoch:',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 0, 0, 0),
                                    child: Consumer<WalletProvider>(
                                        builder: (context, wallet, child) {
                                      return Text(
                                          "${wallet.selectedAccount.epochProofs}");
                                    }),
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
                                      'Last Epoch Mined:',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 0, 0, 0),
                                    child: Consumer<WalletProvider>(
                                        builder: (context, wallet, child) {
                                      return Text(
                                          "${wallet.selectedAccount.lastEpochMined}");
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
                                              return QrCodeDialog(
                                                  addr:
                                                      Provider.of<WalletProvider>(
                                                              context,
                                                              listen: false)
                                                          .selectedAccount
                                                          .addr
                                                          .toLowerCase());
                                            })),
                                    ElevatedButton(
                                      child: const Text(' Send '),
                                      onPressed: () => Provider.of<
                                                      WalletProvider>(context,
                                                  listen: false)
                                              .selectedAccount
                                              .watchOnly
                                          ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text("Watch-only account"),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("OK"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            )
                                          : _navigateAndSendTx(context),
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
      ),
    );
  }
}
