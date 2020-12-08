import 'dart:io';
import 'package:dsm_helper/pages/home.dart';
import 'package:dsm_helper/pages/login/login.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neumorphic/neumorphic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool needLogin = true;
  await FlutterDownloader.initialize(debug: true // optional: set false to disable printing logs to console
      );
  String sid = await Util.getStorage("sid");
  String https = await Util.getStorage("https");
  String host = await Util.getStorage("host");
  String port = await Util.getStorage("port");
  String smid = await Util.getStorage("smid");

  if (https.isNotBlank && sid.isNotBlank && host.isNotBlank) {
    Util.baseUrl = "${https == "1" ? "https" : "http"}://$host:$port";
    Util.sid = sid;
    Util.smid = smid;
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
      title: '群辉助手',
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
