// ignore_for_file: unnecessary_null_comparison, prefer_conditional_assignment

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData light = ThemeData.from(
    colorScheme: const ColorScheme.light(
        primary: Color(0xff06061c), secondary: Color.fromARGB(97, 255, 179, 0)),
    useMaterial3: true);

ThemeData dark = ThemeData.from(
    colorScheme: const ColorScheme.dark(
        primary: Color(0xffffb300), secondary: Color.fromARGB(144, 6, 6, 28)),
    useMaterial3: true);

class ThemeProvider extends ChangeNotifier {
  final String key = "theme";
  late SharedPreferences prefs;
  late bool _darkTheme;

  bool get curTheme => _darkTheme;

  ThemeData get theme => _darkTheme ? light : dark; //Getter

  ThemeProvider() {
    _darkTheme = true;
    loadFromPrefs();
  }

  toggleTheme() {
    _darkTheme = !_darkTheme;
    saveToPrefs();
    notifyListeners();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  loadFromPrefs() async {
    _initPrefs().then((e) {
      _darkTheme = prefs.getBool(key) ?? true;
      notifyListeners();
    });
  }

  saveToPrefs() async {
    await _initPrefs();
    prefs.setBool(key, _darkTheme);
  }
}
