# ![alt text](icons/icon-256.png) Oollet - A 0L wallet 
Flutter-based 0L Wallet app for android/ios
- [iOS App](https://apps.apple.com/us/app/oollet-0l-network/id1617356005)
- [Android App](https://play.google.com/store/apps/details?id=io.misko.olwallet)

Latest Oollet Android APK (March 2, 2024):
[Oollet-3.1.38.apk](https://github.com/misko9/0LWallet/raw/main/oollet-3.1.38.apk)

(deprecated with 0L network v6.9 upgrade) Flutter-based tower app for Android (For best experience: plug in the device, from "Developer Options" set "Stay Awake", and keep the app in the foreground. Not recommended on your primary mobile device.)
- [Proof Ripper apk](https://github.com/misko9/0LWallet/raw/proof_ripper/releases/proof_ripper_v1.2.16.apk)

A mobile-first, chrome/web extension second, 0L wallet app.

It is a single codebase for all platforms with an FFI interface to the Libra rust library used by carpe/tower. Mnemonic is stored in secure storage protected by the respective platform's Keychain/Keystore services. Incognito keyboard is also used when inputing sensitive data. The UI is pretty basic right now, but after adding your account, you'll be able to see your balance, tower height, send, and receive. Codebase is common between android/ios/extension.

Some other items on roadmap:
- Improve this README file for easier/clearer setup, there are many dependencies for a dev env
- App lock password
- Creating a new wallet/account (i.e. create mnemonic)
- Improve UI/UX/theme
- Add a switch for the testnet
- Add an address book for easy transfers
- Get the wallet type
- Additional languages
- And more...

## Getting Started
Install all dependencies, build the rust libraries using "make all" from /0LWallet/libra/rust/, 
and build for your platform.

## Dependencies
- Android Studio
  -  NDK 22.1 (23 currently has problems)
  -  cmake
  -  set $ANDROID_NDK_HOME env var
- Xcode
- Flutter SDK: https://docs.flutter.dev/get-started/install
- Dart SDK
- Rustup: https://rustup.rs/
- 0LWallet/libra/rust:
  -   make init
  -   make all
- 0lwallet/ios:
  -   cat ../rust/target/bindings.h >> Classes/LibraPlugin.h
- sudo arch -x86_64 gem install ffi


Notes
- flutter pub run ffigen:setup -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib


