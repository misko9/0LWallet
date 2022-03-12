import 'package:flutter/material.dart';

MyTheme currentTheme = MyTheme();

class MyTheme with ChangeNotifier {
  static bool _isDarkTheme = false;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  //headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
  //headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
  //bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),

  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme(
      primary: Colors.blueGrey, //app bar
      secondary: Colors.white,
      background: Colors.white10,
      surface: Colors.white30,
      onBackground: Colors.white,
      error: Colors.red,
      onError: Colors.red,
      onPrimary: Colors.yellow, // app bar text, actions
      onSecondary: Colors.orange,
      onSurface: Colors.blueAccent,
      brightness: Brightness.light,
    );
    return ThemeData(
      //primaryColor: Colors.lightBlue,
      colorScheme: colorScheme,
      //backgroundColor: Colors.white,
      //scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Lato',
      textTheme: const TextTheme(
        headline1: TextStyle(color: Colors.black),
        headline2: TextStyle(color: Colors.black),
        bodyText1: TextStyle(color: Colors.black),
        bodyText2: TextStyle(color: Colors.black),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.black,
      accentColor: Colors.red,
      backgroundColor: Colors.grey,
      scaffoldBackgroundColor: Colors.grey,
      textTheme: const TextTheme(
        headline1: TextStyle(color: Colors.white),
        headline2: TextStyle(color: Colors.white),
        bodyText1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white),
      ),
    );
  }
}