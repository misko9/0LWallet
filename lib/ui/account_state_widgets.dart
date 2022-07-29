import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/account.dart';
import '../utils/misc.dart';

_walletType(String walletType, bool isValidator) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        Expanded(child: Text("Wallet Type: ", textAlign: TextAlign.end,)),
        Expanded(child: Text(isValidator ? "Validator/$walletType" :
          walletType, textAlign: TextAlign.end,)),
        SizedBox(width: 40,),
      ],
    ),
  );
}

_makeWhole(double makeWhole) {
  return makeWhole > 0.00001
      ? Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: Text("Make whole credits: ", textAlign: TextAlign.end,)),
              Expanded(child: Text(doubleFormatUS(makeWhole), textAlign: TextAlign.end,)),
              SizedBox(width: 40,),
            ],
          ),
      )
      : Container();
}

_unlocked(double unlocked) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        Expanded(child: Text("Unlocked: ", textAlign: TextAlign.end,)),
        Expanded(child: Text(doubleFormatUS(unlocked), textAlign: TextAlign.end,)),
        SizedBox(width: 40,),
      ],
    ),
  );
}

_transferred(double transferred) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        Expanded(child: Text("Transferred: ", textAlign: TextAlign.end,),),
        Expanded(child: Text(doubleFormatUS(transferred), textAlign: TextAlign.end,)),
        SizedBox(width: 40,),
      ],
    ),
  );
}

_ancestry(String ancestry) {
  List<String> ancestryList = ancestry.split(',');
  if(ancestryList.last.isEmpty){
    ancestryList.removeLast();
  }
  int generation = ancestryList.length;
  if (ancestryList.isEmpty) {
    ancestryList.add('Genesis');
  }
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      //mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("Ancestry (Gen ${generation})", style: TextStyle(fontWeight: FontWeight.bold),),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: ancestryList.length,
            itemBuilder: (context, index) {
              return Text(ancestryList[index], textAlign: TextAlign.end, style: TextStyle(fontSize: 13, fontFamily: 'RobotoMono'),);
            }),
      ],
    ),
  );
}

_vouchers(String vouchers) {
  List<String> voucherList = vouchers.split(',');
  if(voucherList.last.isEmpty){
    voucherList.removeLast();
  }
  int voucherSize = voucherList.length;
  if (voucherList.isEmpty) {
    voucherList.add('None');
  }
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("Vouchers ($voucherSize)", style: TextStyle(fontWeight: FontWeight.bold),),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: voucherList.length,
            itemBuilder: (context, index) {
              return Text(voucherList[index], textAlign: TextAlign.end, style: const TextStyle(fontSize: 13, fontFamily: 'RobotoMono'),);
            }),
      ],
    ),
  );
}
// 		1. Allow claim make whole, if > 0
// 	2. Is there anything to show for operator?
normalWalletAccountState(Account account) {
  double makeWhole = account.makeWhole;
  return Column(
    children: [
      _walletType(account.walletType, false),
      _makeWhole(account.makeWhole),
      SizedBox(height: 8,),
    ],
  );
}

// 	1. Allow claim make whole, if > 0
// 4. Check if Validator
// 	1. Get vouchers
// 	2. Get IP of validator/fullnode
// 	3. Proofs in epoch red/green
// 		1. Get web monitor and show:
// 			1. If web monitor is available
// 			2. If port 6180 is open on val
// 			3. If fullnode is accessible and up-to-date (Show RMS?)
// 			4. 5% of votes?
slowWalletAccountState(Account account) {
  return Column(
    children: [
      _walletType(account.walletType, account.isValidator),
      _makeWhole(account.makeWhole),
      _unlocked(account.unlocked),
      _transferred(account.transferred),
      account.isValidator ? _ancestry(account.ancestry) : Container(),
      account.isValidator ? _vouchers(account.vouchers) : Container(),
      SizedBox(height: 8,),
    ],
  );
}

// Check if frozen, or other delays on transfers, or transfers in general
communityWalletAccountState(Account account) {
  return Column(
    children: [
      _walletType(account.walletType, false),
      //_isFrozen(),
      //_consecutiveRejections(),
      //_unfreeze_votes(),
      SizedBox(height: 8,),
    ],
  );
}
