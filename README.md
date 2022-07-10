# ![alt text](icons/ol_logo_whitebg_square/res/mipmap-xhdpi/ic_launcher.png) Oollet - A 0L wallet 
Flutter-based 0L Wallet app for android/ios
- [iOS App](https://apps.apple.com/us/app/oollet-0l-network/id1617356005)
- [Android App](https://play.google.com/store/apps/details?id=io.misko.olwallet)

Currently, slightly more than a proof of concept for a mobile-first, hopefully web/web extension second, 0L wallet app.

It is a single codebase for both platforms with an FFI interface to the Libra rust library used by carpe/tower. Mnemonic is stored in secure storage protected by the respective platform's Keychain/Keystore services. Incognito keyboard is also used when inputing sensitive data. The UI is pretty basic right now, but after adding your account, you'll be able to see your balance, tower height, send, and receive. Codebase is common between android/ios. Since web doesn't support FFI, the next item on my roadmap is to get the rust code to be Webassembly/WASM compatible.

Some other items on roadmap:
- Improve this README file for easier/clearer setup, there are many dependencies for a dev env
- Improve UI/UX/theme
- Add a switch for the testnet
- Add an address book for easy transfers
- Get the wallet type
- Webassembly/WASM support of rust code
- Dark mode support
- Additional languages
- Teams integration!
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


