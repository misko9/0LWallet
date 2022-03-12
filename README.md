# Oollet - A 0L wallet
Flutter-based 0L Wallet

Currently a proof of concept for a mobile-first, hopefully web/web extension second, 0L wallet app.
UI/UX theme needs work.

It is a single flutter/dart/rust codebase with an FFI interface to the same rust code used by carpe/tower, 
stripped of non-compatible code (filesystem, networking, etc). Private data is stored in secure storage 
protected by the TEE/Secure Enclave. Keyboard input of sensitive data such as mnemonic uses the incognito keyboard. 
Codebase is common between android/ios. Since web doesn't support FFI, the next item on my roadmap is to 
get the rust code to be Webassembly/WASM compatible.

Some other items on roadmap:
Improve this README file for easier/clearer setup, there are many dependencies for a dev env
Improve UI/UX/theme
Add a switch for the testnet
Add an address book for easy transfers
Get the wallet type
Webassembly/WASM support of rust code
Dark mode support
Additional languages
Teams integration!
And more...

## Getting Started
Install all dependencies, build the rust libraries using "make all" from /0LWallet/lib/rust/, 
and build for your platform.

## Dependencies
Android Studio
  NDK 22.1 (23 currently has problems)
  cmake
  set $ANDROID_NDK_HOME env var
Xcode
Flutter SDK: https://docs.flutter.dev/get-started/install
Dart SDK
Rustup: https://rustup.rs/
0lwallet/rust:
  brew install openssl
  export OPENSSL_INCLUDE_DIR=`brew --prefix openssl`/include
  export OPENSSL_LIB_DIR=`brew --prefix openssl`/lib
  make init
  make all
0lwallet/ios:
  cat ../rust/target/bindings.h >> Classes/LibraPlugin.h
sudo arch -x86_64 gem install ffi


Notes
flutter pub run ffigen:setup -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib



