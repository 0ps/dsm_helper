import 'package:dsm_helper/util/function.dart';
import 'package:flutter/material.dart';

class DarkModeProvider with ChangeNotifier {
  /// 深色模式 0: 关闭 1: 开启 2: 随系统
  int _darkMode = 2;
  int get darkMode => _darkMode;
  DarkModeProvider(this._darkMode);
  void changeMode(int darkMode) async {
    _darkMode = darkMode;
    notifyListeners();
    Util.setStorage("dark_mode", _darkMode.toString());
  }
}
