
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wallet_provider.dart';
import '../../utils/misc.dart';
class NameInputField extends StatefulWidget {
  const NameInputField({
    Key? key,
    required this.nameController1,
  }) : super(key: key);
  final TextEditingController nameController1;

  @override
  State<NameInputField> createState() => _NameInputFieldState();
}

class _NameInputFieldState extends State<NameInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (_) =>
          EasyDebounce.debounce(
            '_nameController1',
            const Duration(milliseconds: 1000),
                () => setState(() {}),
          ),
      maxLength: 30,
      validator: (text) {
        if (text == null || text.isEmpty) {
          return 'Enter an account name';
        }
        if (text.length > 30) {
          return 'Name too long';
        }
        var accounts = Provider
            .of<WalletProvider>(context, listen: false)
            .accountsList;
        if (accounts.any((element) => equalsIgnoreCase(element.name, text)) ||
            equalsIgnoreCase(text, WalletProvider.nonAccount.name)) {
          return 'Name taken, please choose another';
        }
        return null;
      },
      controller: widget.nameController1,
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
        suffixIcon: widget.nameController1.text.isNotEmpty
            ? InkWell(
          onTap: () =>
              setState(
                    () => widget.nameController1.clear(),
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
}
