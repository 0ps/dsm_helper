import 'package:dsm_helper/util/function.dart';
import 'package:flutter/material.dart';

class WallpaperProvider with ChangeNotifier {
  bool _showWallpaper = true;
  bool get showWallpaper => _showWallpaper;
  WallpaperProvider(this._showWallpaper);
  void changeMode(bool showWallpaper) async {
    _showWallpaper = showWallpaper;
    notifyListeners();
    Util.setStorage("show_wallpaper", showWallpaper ? "1" : "0");
  }
}
