import 'package:bip39/bip39.dart' as bip39;
import 'package:tweetnacl/tweetnacl.dart';
import 'dart:typed_data';

// FreshLibra is a class using pure dart/flutter
class FreshLibra {
  static bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  static String getAddrFromMnemonic(String mnemonic) {
    var seedStr = bip39.mnemonicToSeedHex(mnemonic);
    // Can I just use, bip39.mnemonicToSeed? (returns Uint8 List)

    // 1. Get mnemonic into an array of words, checking the checksum
    // 2.
    List<int> seed = TweetNaclFast.hexDecode(seedStr);
    KeyPair kp = Signature.keyPair_fromSeed(Uint8List.fromList(seed));
    return kp.publicKey.toString();
  }


  //String testString = "test string";
  //Uint8List bytes = utf8.encode(testString);

  //Signature s1 = Signature(null, kp.secretKey);
  //print("\ndetached...@${DateTime.now().millisecondsSinceEpoch}");
  //Uint8List signature = s1.detached(bytes);
  //print("...detached@${DateTime.now().millisecondsSinceEpoch}");

  //Signature s2 = Signature(kp.publicKey, null);
  //print("\nverify...@${DateTime.now().millisecondsSinceEpoch}");
  //bool result = s2.detached_verify(bytes,  signature);
  //print("...verify@${DateTime.now().millisecondsSinceEpoch}");

  //assert(result == true);
}