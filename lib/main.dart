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
      systemNavigationBarColor: Color(0xFFF4F4F4),
    ));
  }
}

class MyApp extends StatelessWidget {
  final bool needLogin;
  MyApp(this.needLogin);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Station',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          color: Color(0xFFF4F4F4),
          iconTheme: IconThemeData(color: Colors.black),
          actionsIconTheme: IconThemeData(color: Colors.black),
          textTheme: TextTheme(headline6: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black)),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFF4F4F4),
      ),
      home: needLogin ? Login() : Home(),
      routes: {
        "/login": (BuildContext context) => Login(),
        "/home": (BuildContext context) => Home(),
      },
    );
  }
}
