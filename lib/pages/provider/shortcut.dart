import 'package:dsm_helper/util/function.dart';
import 'package:flutter/material.dart';

class ShortcutProvider with ChangeNotifier {
  bool _showShortcut = true;
  bool get showShortcut => _showShortcut;
  ShortcutProvider(this._showShortcut);
  void changeMode(bool showShortcut) async {
    _showShortcut = showShortcut;
    notifyListeners();
    Util.setStorage("show_shortcut", showShortcut ? "1" : "0");
  }
}
