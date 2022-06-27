import 'package:flutter/material.dart';

class CreateNewAccount extends StatelessWidget{
  static const route = '/CreateNewAccount';
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Create New Account'),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: const Center(
            child: Text('Use Carpe to create a new account'),
          ),
        ),
      )
    );
  }
}
