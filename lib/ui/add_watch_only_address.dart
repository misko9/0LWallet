import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/wallet_provider.dart';
import '../utils/misc.dart';
import 'barcode_scanner.dart';
import 'common/name_input_field.dart';
import 'wallet_home.dart';

class AddWatchOnlyAddress extends StatefulWidget {
  const AddWatchOnlyAddress({Key? key}) : super(key: key);
  static const route = '/AddWatchOnlyAddress';

  @override
  State<AddWatchOnlyAddress> createState() => _AddWatchOnlyAddressState();
}

class _AddWatchOnlyAddressState extends State<AddWatchOnlyAddress> {
  late TextEditingController nameController1;
  late TextEditingController _addrController2;
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController1 = TextEditingController();
    _addrController2 = TextEditingController();
  }

  /*Widget _buildNameInput() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (_) => EasyDebounce.debounce(
        '_nameController1',
        const Duration(milliseconds: 1000),
            () => setState(() {}),
      ),
      maxLength: 30,
      validator: (text) {
        if(text == null || text.isEmpty) {
          return 'Enter an account name';
        }
        if(text.length > 30) {
          return 'Name too long';
        }
        var accounts = Provider.of<WalletProvider>(context, listen: false).accountsList;
        if(accounts.any((element) => equalsIgnoreCase(element.name, text)) ||
            equalsIgnoreCase(text, WalletProvider.nonAccount.name)) {
          return 'Name taken, please choose another';
        }
        return null;
      },
      controller: _nameController1,
      obscureText: false,
      decoration: InputDecoration(
        hintText: 'i.e. first miner',
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
        suffixIcon: _nameController1.text.isNotEmpty
            ? InkWell(
          onTap: () => setState(
                () => _nameController1.clear(),
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
    );
  }*/

  Widget _buildAddressInput() {
    return
      TextFormField(
        enableSuggestions: false,
        autocorrect: false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLength: 32,
        onChanged: (_) => EasyDebounce.debounce(
          '_addrController2',
          const Duration(milliseconds: 1000),
              () => setState(() {
          }),
        ),
        validator: (text) {
          if(text == null || text.isEmpty) {
            return 'Enter 0L address';
          }
          if(text.length != 32) {
            return 'Invalid 0L address';
          }
          var accounts = Provider.of<WalletProvider>(context, listen: false).accountsList;
          if(accounts.any((element) => element.addr.toLowerCase() == text.toLowerCase())) {
            return 'Account already in wallet';
          }
          return null;
        },
        controller: _addrController2,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "0L address",
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x00000000),
              width: 1,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.0),
              topRight: Radius.circular(4.0),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
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
          suffixIcon: _addrController2.text.isNotEmpty ? InkWell(
            onTap: () => setState(
                  () => _addrController2.clear(),
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
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Add Watch-Only Account'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.paste,
              color: Colors.white,
            ),
            onPressed: () {
              Clipboard.getData('text/plain').then((value) {
                _addrController2.text = value?.text ?? "";
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
                  _addrController2.text = addr;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                shape: BoxShape.rectangle,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4.0, 4.0, 0.0, 2.0),
                      child: Text(
                        'Account name:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    NameInputField(nameController1: nameController1),
                    _buildAddressInput(),
                    Align(
                      alignment: const AlignmentDirectional(1, 0),
                      child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                          child: ElevatedButton(
                            onPressed: _validate,
                            child: const Text('Submit'),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validate() {
    final form = _formKey.currentState;
    bool? valid = form?.validate();
    if(valid != null && valid == true) { // Validation passes
      var name = nameController1.value.text;
      var addr = _addrController2.value.text.toLowerCase();
      Provider.of<WalletProvider>(context, listen: false).addNewAccountByAddr(name, addr);
      Provider.of<WalletProvider>(context, listen: false).setNewSelectedAccount(addr);
      Navigator.pushReplacementNamed(context, WalletHome.route);
      // Save new account and open it
    }
  }
}
