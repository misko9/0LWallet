import Flutter
import UIKit

public class SwiftLibraPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "libra", binaryMessenger: registrar.messenger())
    let instance = SwiftLibraPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }

  public func dummyMethodToEnforceBundling() {
      //rust_greeting("...");
      get_addr_from_mnem("...");
      //rust_add(1,2);
      is_mnem_valid("...");
      rust_balance_transfer(1, 2, "1", "2");
      rust_community_balance_transfer(1, 2, "1", "2");
      rust_claim_make_whole(1, "1");
      rust_get_make_whole_credits_from_state("1");
      rust_is_make_whole_claimed_from_state("1");
      rust_get_ancestry_from_state("1");
      rust_get_vouchers_from_state("1");
      rust_get_wallet_type_from_state("1");
      rust_is_validator_from_state("1");
      rust_is_operator_from_state("1");
      rust_get_unlocked_from_state("1");
      rust_get_transferred_from_state("1");
      //rust_cstr_free("1");
      // ...
      // This code will force the bundler to use these functions, but will never be called
    }
}
