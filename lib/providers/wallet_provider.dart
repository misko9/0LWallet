import 'package:flutter/material.dart';
import 'package:libra/libra.dart';
import '../models/account.dart';
import '../services/account_services.dart';

enum ReturnStatus {
  okay,
  duplicate
}

class WalletProvider extends ChangeNotifier {
  final services = AccountServices();
  List<Account> _accountsListCache = [];
  static final nonAccount = Account(name: 'Not initialized', addr: 'abcdefgh', watchOnly: true);
  int selectedAccountIndex = 0;
  Account _selectedAccount = nonAccount;
  bool _engModeEnabled = false;

  // This public getter cannot be modified by any other object
  List<Account> get accountsList => List.unmodifiable(_accountsListCache);
  Account get noWalletAccount => nonAccount;
  Account get selectedAccount => _selectedAccount;
  bool get engModeEnabled => _engModeEnabled;

  // Don't change case here, early versions allowed uppercase addresses
  Future<String> getMnemonic(String addr) async {
    return await services.getMnemonic(addr);
  }

  Future<int> getAccountListSizeAndInit() async {
    _accountsListCache = await services.getAllAccounts();
    String selectedAccountFromStorage = await services.getSelectedAccount();
    if(_accountsListCache.isNotEmpty){
      _accountsListCache.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if(selectedAccountFromStorage != nonAccount.addr) {
        _selectedAccount = _accountsListCache
            .firstWhere((element) => element.addr == selectedAccountFromStorage,
            orElse: () => nonAccount);
      } else {
        _selectedAccount = _accountsListCache.first;
      }
      // Fetch data
    }
    return _accountsListCache.length;
  }

  // addr should not change case
  void setNewSelectedAccount(String addr) {
    if(_selectedAccount.addr != addr) {
      _selectedAccount =
          _accountsListCache.firstWhere((element) => element.addr == addr,
              orElse: () => nonAccount);
      services.setSelectedAccount(addr);
      if (_selectedAccount.addr != nonAccount.addr) {
        // Fetch data
      }
      notifyListeners();
    }
  }

  ReturnStatus addNewAccountByMnem(String name, String mnemonic) {
    String addr = Libra().get_address_from_mnem(mnemonic).toLowerCase();
    if (_accountsListCache.any((element) => element.addr == addr)) {
      return ReturnStatus.duplicate;
    }
    var newAccount = Account(name: name, addr: addr, watchOnly: false);
    _accountsListCache.add(newAccount);
    _accountsListCache.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    services.createAccount(newAccount, mnemonic);
    notifyListeners();
    return ReturnStatus.okay;
  }

  ReturnStatus addNewAccountByAddr(String name, String addr) {
    var newAccount = Account(name: name, addr: addr.toLowerCase(), watchOnly: true);
    _accountsListCache.add(newAccount);
    _accountsListCache.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    services.createAccount(newAccount, "");
    notifyListeners();
    return ReturnStatus.okay;
  }

  void saveAccount(Account account) {
    if(_selectedAccount.addr.toLowerCase() == account.addr.toLowerCase()){
      _selectedAccount.name = account.name;
      _selectedAccount.balance = account.balance;
      _selectedAccount.towerHeight = account.towerHeight;
      _selectedAccount.walletType = account.walletType;
      _selectedAccount.seqNum = account.seqNum;
      _selectedAccount.epochProofs = account.epochProofs;
      _selectedAccount.watchOnly = account.watchOnly;
    }

    Account accountCache = _accountsListCache.firstWhere((element) => account.addr.toLowerCase() == element.addr.toLowerCase(), orElse: () => Account(name: "", addr: "", watchOnly: true));
    accountCache.name = account.name;
    accountCache.balance = account.balance;
    accountCache.towerHeight = account.towerHeight;
    accountCache.walletType = account.walletType;
    accountCache.seqNum = account.seqNum;
    accountCache.epochProofs = account.epochProofs;
    accountCache.lastEpochMined = account.lastEpochMined;
    accountCache.watchOnly = account.watchOnly;

    _accountsListCache.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    services.saveAccount(account);
    notifyListeners();
  }

  void deleteAccount(Account account) {
    _accountsListCache.removeWhere((element) => account.addr.toLowerCase() == element.addr.toLowerCase());
    services.delete(account);
    if(_selectedAccount.addr.toLowerCase() == account.addr.toLowerCase()) {
      if(_accountsListCache.isNotEmpty) {
        _selectedAccount = _accountsListCache.first;
      } else {
        _selectedAccount =
            nonAccount;
      }
      services.setSelectedAccount(_selectedAccount.addr);
    }
    notifyListeners();
  }

  void setEngMode(bool value) {
    _engModeEnabled = value;
    notifyListeners();
  }
}
