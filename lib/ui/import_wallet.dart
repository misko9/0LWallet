import 'package:Oollet/utils/misc.dart';
import 'package:flutter/material.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:libra/libra.dart';
import '../account_provider.dart';
import '../utils/word_list.dart';
import 'wallet_home.dart';

class ImportWallet extends StatefulWidget {
  static const route = '/ImportWallet';

  @override
  _ImportWalletState createState() => _ImportWalletState();
}

class _ImportWalletState extends State<ImportWallet> {
  late TextEditingController _nameController1;
  late TextEditingController _mnemController2;
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController1 = TextEditingController();
    _mnemController2 = TextEditingController();
  }

  Widget _buildNameInput() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (_) => EasyDebounce.debounce(
        '_nameController1',
        const Duration(milliseconds: 1000),
            () => setState(() {}),
      ),
      validator: (text) {
        if(text == null || text.isEmpty) {
          return 'Enter an account name';
        }
        if(text.length > 50) {
          return 'Name too long';
        }
        var accounts = AccountProvider.of(context).cachedAccounts;
        if(accounts.any((element) => equalsIgnoreCase(element.name, text))) {
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
            size: 22,
          ),
        )
            : null,
      ),
      maxLines: 1,
    );
  }

  Widget _buildMnenomicInput() {
    return
      TextFormField(
        keyboardType: TextInputType.visiblePassword,
        enableIMEPersonalizedLearning: false,
        enableSuggestions: false,
        autocorrect: false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (_) => EasyDebounce.debounce(
          '_mnemController2',
          const Duration(milliseconds: 1000),
              () => setState(() {
                // Check each word, underline in red if not in set
                // Check number of words
              }),
        ),
        validator: (text) {
          if(text == null || text.isEmpty) {
            return 'Enter mnemonic';
          }
          var splitted = text.trim().split(' ');
          if (splitted.length != 24) {
            return 'List requires 24 words, ${24-splitted.length} more';
          }
          if(!(splitted.every((element1) => wordList.any((element2) => element1 == element2)))){
            return 'At least one word is not valid';
          }
          //if(!FreshLibra.validateMnemonic(text.trim())) {
          //  return "FreshLibra caught invalid checksum";
          //}
          if(!Libra().is_mnem_valid(text)) {
            return 'Checksum is invalid';
          }
          var addr = Libra().get_address_from_mnem(text);
          var accounts = AccountProvider.of(context).cachedAccounts;
          if(accounts.any((element) => element.addr == addr)) {
            return 'Account already in wallet';
          }
          return null;
        },
        controller: _mnemController2,
        obscureText: false,
        decoration: InputDecoration(
          hintText: 'mnenomic',
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
          suffixIcon: _mnemController2.text.isNotEmpty ? InkWell(
            onTap: () => setState(
                  () => _mnemController2.clear(),
            ),
            child: const Icon(
              Icons.clear,
              color: Color(0xFF757575),
              size: 22,
            ),
          )
              : null,
        ),
        maxLines: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Import Account'),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
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
                    _buildNameInput(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 2.0),
                      child: Text(
                        'Mnemonic to import:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    _buildMnenomicInput(),
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
      var name = _nameController1.value.text;
      var mnem = _mnemController2.value.text;
      var addr = Libra().get_address_from_mnem(mnem);
      AccountProvider.of(context).addNewAccount(name, mnem);
      AccountProvider.of(context).setNewSelectedAccount(addr);
      Navigator.pushReplacementNamed(context, WalletHome.route);
      // Save new account and open it
    }
  }
}