import 'dart:io';
import 'package:file_station/pages/home.dart';
import 'package:file_station/pages/login/login.dart';
import 'package:file_station/util/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool needLogin = true;
  String sid = await Util.getStorage("sid");
  String host = await Util.getStorage("host");
  if (sid.isNotBlank && host.isNotBlank) {
    Util.baseUrl = host;
    Util.sid = sid;
    needLogin = false;
  }
  runApp(MyApp(needLogin));
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFf4f4f4),
    ));
  }
}

class MyApp extends StatelessWidget {
  final bool needLogin;
  MyApp(this.needLogin);
  @override
  Widget build(BuildContext context) {
    return NeuApp(
      title: 'File Station',
      debugShowCheckedModeBanner: false,
      theme: NeuThemeData.light().copyWith(),
      darkTheme: NeuThemeData.dark(),
      home: needLogin ? Login() : Home(),
      routes: {
        "/login": (BuildContext context) => Login(),
        "/home": (BuildContext context) => Home(),
      },
    );
  }
}
