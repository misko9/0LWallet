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
      primary: Colors.black87, //app bar
      secondary: Colors.blue, // Settings switch icon on
      background: Colors.white10,
      surface: Colors.white30,
      onBackground: Colors.white,
      error: Colors.red,
      onError: Colors.red,
      onPrimary: Colors.yellow, // app bar text, actions
      onSecondary: Colors.orange,
      onSurface: Colors.black87,
      brightness: Brightness.light,
    );
    ListTileThemeData listTileTheme = ListTileThemeData(
      dense: true,
      //iconColor: Colors.white,
      //selectedColor: Colors.blue,
      //selectedTileColor: Color(0xff170f34),
      //textColor: Colors.white,
      //contentPadding: EdgeInsets.all(5.0),
      //tileColor: Color(0xff2d2755),
    );
    return ThemeData(
      //primaryColor: Colors.lightBlue,
      colorScheme: colorScheme,
      //backgroundColor: Colors.white,
      //scaffoldBackgroundColor: Colors.white,
      listTileTheme: listTileTheme,
      fontFamily: 'Lato',
      textTheme: const TextTheme(
        headline1: TextStyle(color: Colors.black),
        headline2: TextStyle(color: Colors.black),
        //headline6: TextStyle(color: Colors.green), // Settings Page Tile title
        bodyText1: TextStyle(color: Colors.black),
        bodyText2: TextStyle(color: Colors.black),
        //subtitle2: TextStyle(color: Colors.blue), // Settings Page subtitle tile
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