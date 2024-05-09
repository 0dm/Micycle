import 'package:Micycle/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Private constructor.
  ThemeProvider._privateConstructor();
  double _fontSize = 16.0;

  // The single instance of ThemeProvider.
  static final ThemeProvider _instance = ThemeProvider._privateConstructor();

  // Getter to access the single instance.
  static ThemeProvider get instance => _instance;
  double get fontSize => _fontSize;
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
  }
  void increaseFontSize() {
    _fontSize += 2.0;
    notifyListeners();
  }

  void decreaseFontSize() {
    _fontSize -= 2.0;
    notifyListeners();
  }
  set fontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }
}