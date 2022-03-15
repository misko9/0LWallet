import 'package:flutter/material.dart';
import 'controllers/account_controller.dart';

class AccountProvider extends InheritedWidget {
  final _controller = AccountController();

  AccountProvider({Key? key, required Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static AccountController of(BuildContext context) {
    AccountProvider provider = context.dependOnInheritedWidgetOfExactType<AccountProvider>()!;
    return provider._controller;
  }

}