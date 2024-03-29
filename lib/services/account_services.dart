import 'package:Oollet/providers/wallet_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';

class AccountServices {
  final _secureRepository = const FlutterSecureStorage();
  static const String _keySelected = "Selected";
  static const String _keyEngModeAvailable = "EngModeAvail";

  Future<void> createAccount(Account newAccount, String mnem) async {
    var _sharedPref = await SharedPreferences.getInstance();
    await _sharedPref.setString(newAccount.addr, Account.serialize(newAccount));
    if(newAccount.watchOnly == false) {
      await _secureRepository.write(key: newAccount.addr, value: mnem);
    }
  }

  Future<void> saveAccount(Account account) async {
    var _sharedPref = await SharedPreferences.getInstance();
    await _sharedPref.setString(account.addr, Account.serialize(account));
  }

  Future<void> delete(Account account) async {
    var _sharedPref = await SharedPreferences.getInstance();
    await _sharedPref.remove(account.addr);
    await _secureRepository.delete(key: account.addr);
  }

  Future<void> deleteAll() async {
    await _secureRepository.deleteAll();
    var _sharedPref = await SharedPreferences.getInstance();
    await _sharedPref.clear();
  }

  Future<Account> getAccount(String addr) async {
    var _sharedPref = await SharedPreferences.getInstance();
    var _readAccount = _sharedPref.getString(addr);
    return _readAccount != null ?
      Account.deserialize(addr, _readAccount) :
      Account(name: "Invalid", addr: addr, watchOnly: true);
  }

  Future<List<Account>> getAllAccounts() async {
    var _sharedPref = await SharedPreferences.getInstance();
    var _accountKeys = _sharedPref.getKeys();
    List<Account> _accountList = [];
    for (var key in _accountKeys) {
      var account = _sharedPref.getString(key);
      if ((key != _keySelected) && (key != _keyEngModeAvailable) && account != null) {
        _accountList.add(Account.deserialize(key, account));
      }
    }
    return _accountList;
  }

  Future<String> getMnemonic(String addr) async {
    var _mnem = await _secureRepository.read(key: addr);
    return _mnem ?? "";
  }

  Future<String> getSelectedAccount() async {
    var sharedPref = await SharedPreferences.getInstance();
    var readSelectedAccount = sharedPref.getString(_keySelected);
    return readSelectedAccount ?? WalletProvider.nonAccount.addr;
  }

  Future setSelectedAccount(String selectedAccount) async {
    var sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString(_keySelected, selectedAccount);
  }

  Future<bool> getEngModeAvail() async {
    var sharedPref = await SharedPreferences.getInstance();
    var readSelectedAccount = sharedPref.getString(_keyEngModeAvailable);
    return ((readSelectedAccount != null) && (readSelectedAccount == "true")) ? true : false;
  }

  Future setEngModeAvail(bool engModeAvailable) async {
    var sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString(_keyEngModeAvailable, engModeAvailable.toString());
  }
}