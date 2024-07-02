import 'package:flutter/material.dart';

class MyTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    hintColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.white,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    hintColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.grey[900],
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkModeEnabled = false;

  bool get isDarkModeEnabled => _isDarkModeEnabled;

  void toggleTheme() {
    _isDarkModeEnabled = !_isDarkModeEnabled;
    notifyListeners();
  }

  ThemeData get themeData =>
      _isDarkModeEnabled ? MyTheme.darkTheme : MyTheme.lightTheme;
}
