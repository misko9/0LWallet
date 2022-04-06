import 'package:libra/libra.dart';
import '../models/account.dart';
import '../services/account_services.dart';

enum ReturnStatus {
  okay,
  duplicate
}

class AccountController {
  final services = AccountServices();
  List<Account> _cachedAccountList = [];
  static final nonAccount = Account(name: 'Not initialized', addr: 'abcdefgh', towerHeight: 0, walletType: 'normal', balance: 0.0);
  int selectedAccountIndex = 0;
  Account _selectedAccount = nonAccount;

  Future<String> getMnemonic(String addr) async {
    return await services.getMnemonic(addr);
  }

  Future<int> getAccountListSizeAndInit() async {
    _cachedAccountList = await services.getAllAccounts();
    if(_cachedAccountList.isNotEmpty && _selectedAccount.addr == nonAccount.addr){
      _selectedAccount = _cachedAccountList.first;
    }
    return _cachedAccountList.length;
  }

  Account get selectedAccount => _selectedAccount;
  void setNewSelectedAccount(String addr) {
    _selectedAccount = _cachedAccountList.firstWhere((element) => element.addr == addr);
  }

  // This public getter cannot be modified by any other object
  List<Account> get cachedAccounts => List.unmodifiable(_cachedAccountList);

  ReturnStatus addNewAccount(String name, String mnemonic) {
    String addr = Libra().get_address_from_mnem(mnemonic);
    if (_cachedAccountList.any((element) => element.addr == addr)) {
      return ReturnStatus.duplicate;
    }

    var newAccount = Account(name: name, addr: addr);
    _cachedAccountList.add(newAccount);
    services.createAccount(newAccount, mnemonic);
    return ReturnStatus.okay;
  }

  void saveAccount(Account account) {
    // Don't use without updating cache
    services.saveAccount(account);
  }

  void deleteAccount(Account account) {
    _cachedAccountList.removeWhere((element) => account.addr == element.addr);
    services.delete(account);
    if (_cachedAccountList.isNotEmpty) {
      _selectedAccount = _cachedAccountList.first;
    }
  }
}