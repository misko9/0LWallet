import 'dart:ui';

import 'package:Oollet/providers/wallet_provider.dart';
import 'package:Oollet/services/rpc_services.dart';
import 'package:Oollet/ui/barcode_scanner.dart';
import 'package:Oollet/ui/wallet_home.dart';
import 'package:Oollet/utils/misc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libra/libra.dart';
import 'package:libra/libra_rpc.dart';
import 'package:provider/provider.dart';

import '../models/account.dart';

class SendTransaction extends StatefulWidget {
  static const route = '/SendTransaction';

  const SendTransaction({Key? key}) : super(key: key);

  @override
  State<SendTransaction> createState() => _SendTransactionState();
}

class _SendTransactionState extends State<SendTransaction>
    with TickerProviderStateMixin {
  late TextEditingController _recipientController1;
  late TextEditingController _amountController2;
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var _sendButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _recipientController1 = TextEditingController();
    _amountController2 = TextEditingController();
  }

  Widget _formRecipient(Account account) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (_) => EasyDebounce.debounce(
        '_recipientController1',
        Duration(milliseconds: 1000),
        () => setState(() {}),
      ),
      validator: (text) {
        if (text == null || text.isEmpty) {
          return 'Enter an recipient address';
        }
        if (text.length < 32) {
          return 'Address too short';
        }
        if (text.length > 32) {
          return 'Address too long';
        }
        for (int i = 0; i < 32; i += 8) {
          final hex = text.substring(i, i + 8);
          final parsedNum = int.tryParse(hex, radix: 16);
          if (parsedNum == null) {
            return 'Invalid input';
          }
          print("Parsed Num" + parsedNum.toString());
        }
        if (equalsIgnoreCase(account.addr, text)) {
          return 'This is the source account, please choose another';
        }
        return null;
      },
      style: const TextStyle(
        fontSize: 15.0,
      ),
      controller: _recipientController1,
      obscureText: false,
      decoration: InputDecoration(
        hintText: '1A2B...3C4D',
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x00000000),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(4.0),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x00000000),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(4.0),
          ),
        ),
        filled: true,
        suffixIcon: _recipientController1.text.isNotEmpty
            ? InkWell(
                onTap: () => setState(
                  () => _recipientController1.clear(),
                ),
                child: const Icon(
                  Icons.clear,
                  color: Color(0xFF757575),
                  size: 18,
                ),
              )
            : SizedBox(height: 18),
      ),
      maxLines: 1,
      maxLength: 32,
    );
  }

  Widget _formAmount(Account account) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (_) => EasyDebounce.debounce(
        '_amountController2',
        const Duration(milliseconds: 1000),
        () => setState(() {}),
      ),
      validator: (text) {
        if (text == null || text.isEmpty) {
          return 'Enter # of coins';
        }
        if (text.length > 9) {
          return 'Come on, really? :)';
        }
        var amount = int.tryParse(text);
        if (amount == null) {
          return 'Invalid number';
        }
        if (account.balance < amount) {
          return 'Not enough funds';
        }
        return null;
      },
      style: const TextStyle(
        fontSize: 16.0,
      ),
      controller: _amountController2,
      obscureText: false,
      decoration: InputDecoration(
        hintText: '0',
        //fillColor: Colors.grey,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x00000000),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(4.0),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x00000000),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(4.0),
          ),
        ),
        filled: true,
        suffixIcon: _amountController2.text.isNotEmpty
            ? InkWell(
                onTap: () => setState(
                  () => _amountController2.clear(),
                ),
                child: const Icon(
                  Icons.clear,
                  color: Color(0xFF757575),
                  size: 18,
                ),
              )
            : SizedBox(height: 18.0,),
      ),
      maxLines: 1,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ], // Only numbers can be entered
    );
  }

  Widget _allInputFields(Account account) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(6.0, 10.0, 0.0, 2.0),
              child: Text(
                'Recipient address:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
              child: _formRecipient(account),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(6.0, 0, 0.0, 2.0),
              child: Text(
                'Amount (GAS):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 4.0, 200.0, 0),
              child: _formAmount(account),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.0, 0, 8.0, 8.0),
                  child: Text(
                    'Max tx fee is .01 GAS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var account =
        Provider.of<WalletProvider>(context, listen: false).selectedAccount;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Send Transaction'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.paste,
              color: Colors.white,
            ),
            onPressed: () {
              Clipboard.getData('text/plain').then((value) {
                _recipientController1.text = value?.text ?? "";
                setState(() {});
              });
              //_navigateAndGetAccount(context);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            ),
            onPressed: () async {
              String addr = "";
              addr = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BarcodeScannerWithController()),
              );
              setState(() {
                if (addr != null && addr != "") {
                  _recipientController1.text = addr;
                }
              });
              //_navigateAndGetAccount(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8.0),
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: const Color(0xFFF5F5F5),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Row(children: [
                          Icon(Icons.account_balance_wallet_outlined),
                        ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.70,
                              child: Center(
                                child: Text(
                                  account.name,
                                  style: TextStyle(fontSize: 18.0),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(account.addr.toLowerCase()),
                      ],
                    ),
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
                        doubleFormatUS(account.balance > .005 ?
                          account.balance - .005 : account.balance), // Fix rounding up
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
                  _allInputFields(account),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _cancelButton(context),
                      SizedBox(width: 20),
                      _sendButton(context, account),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validate(Account account) {
    final form = _formKey.currentState;
    bool? valid = form?.validate();
    if (valid != null && valid == true) {
      // Validation passes
      var recipient = _recipientController1.value.text;
      var amount = int.tryParse(_amountController2.value.text) ?? 0;
      FocusManager.instance.primaryFocus?.unfocus();
      _confirmSendDialog(account, recipient, amount);
    }
  }

  _confirmSendDialog(Account account, String recipient, int amount) {
    // set up the button
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () => Navigator.of(context).pop(),
    );

    // set up the button
    Widget okButton = TextButton(
      child: const Text("Send"),
      onPressed: () {
        _sendButtonDisabled = true;
        _sendTransaction(account, recipient, amount);
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      scrollable: true,
      title: const Text("Confirm transaction"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Recipient:',
            style: TextStyle(fontSize: 14),
          ),
          Text(
            recipient,
            style: const TextStyle(fontSize: 12),
          ),
          Text(''),
          Text('Amount: ' + amount.toString() + " GAS"),
        ],
      ),
      actions: [
        cancelButton,
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

  _sendTransaction(Account account, String destAddr, int coins) async {
    WalletProvider walletProvider =
        Provider.of<WalletProvider>(context, listen: false);
    await RpcServices.fetchAccountInfo(walletProvider, account, false);
    int seqNum = account.seqNum;
    String mnem = await walletProvider.getMnemonic(account.addr);
    var signedTx = Libra().balance_transfer(destAddr, coins, mnem, seqNum);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 18),
      content: Row(
        children: const <Widget>[
          CircularProgressIndicator(),
          Text("   Sending...")
        ],
      ),
    ));
    debugPrint(signedTx);
    var submitStatus = await LibraRpc.submitRpc(signedTx);
    debugPrint("Submit status: " + submitStatus.toString());
    var statusString = "Timed-out";
    if (submitStatus == -99999) {
      statusString = "Failure - can't connect";
      _sendButtonDialogTemp(context, statusString, account);
    } else {
      for (int i = 0; i < 20; i++) {
        debugPrint("Waiting for tx: " + i.toString());
        await Future.delayed(const Duration(seconds: 1));
        var txStatus =
            await LibraRpc.getAccountTransaction(account.addr, seqNum);
        if (txStatus == 0) {
          debugPrint("Tx complete!");
          statusString = "Success";
          break;
        } else if (txStatus == -127) {
          debugPrint("Tx completed with move_abort");
          statusString = "Failed, move abort";
          break;
        } else if (txStatus == -128) {
          debugPrint("Tx completed with move_abort & null");
          statusString = "Failed, is account on-chain?";
          break;
        }
      }
      _sendButtonDialogTemp(context, statusString, account);
    }
  }

  Widget _cancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text('Cancel'),
    );
  }

  Widget _sendButton(BuildContext context, Account account) {
    return ElevatedButton(
      onPressed: () {
        if (_sendButtonDisabled != true) {
          _validate(account);
        }
      },
      child: Text(' Send '),
    );
  }

  _sendButtonDialogTemp(BuildContext context, String status, Account account) {
    ScaffoldMessenger.of(context).clearSnackBars();
    _sendButtonDisabled = false;
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        WalletProvider walletProvider =
            Provider.of<WalletProvider>(context, listen: false);
        RpcServices.fetchAccountInfo(walletProvider, account, false);
        Navigator.of(context).popUntil(ModalRoute.withName(WalletHome.route));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Transaction Complete"),
      content: Text(status),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
