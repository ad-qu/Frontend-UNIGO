import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/widgets/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();

    saveThemeData(themeData);
  }

  Future<void> saveThemeData(ThemeData themeData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', themeData == darkMode ? 'dark' : 'light');
  }

  Future<void> loadThemeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme');
    if (theme != null) {
      if (theme == 'dark') {
        themeData = darkMode;
      } else {
        themeData = lightMode;
      }
    }
  }

  void toggleTheme() {
    if (_themeData == darkMode) {
      themeData = lightMode;
    } else {
      themeData = darkMode;
    }
  }
}
