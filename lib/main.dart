import 'dart:io';
import 'package:dsm_helper/pages/home.dart';
import 'package:dsm_helper/pages/login/login.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';

import 'pages/provider/dark_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool needLogin = true;
  await FlutterDownloader.initialize(debug: false);
  await UmengAnalyticsPlugin.init(
    androidKey: '5ffe477d6a2a470e8f76809c',
    iosKey: '5ffe47cb6a2a470e8f7680a2',
  );
  String sid = await Util.getStorage("sid");
  String https = await Util.getStorage("https");
  String host = await Util.getStorage("host");
  String port = await Util.getStorage("port");
  String smid = await Util.getStorage("smid");
  String darkModeStr = await Util.getStorage("dark_mode");
  int darkMode = 2;
  if (darkModeStr.isNotBlank) {
    darkMode = int.parse(darkModeStr);
  }
  if (https.isNotBlank && sid.isNotBlank && host.isNotBlank) {
    Util.baseUrl = "${https == "1" ? "https" : "http"}://$host:$port";
    Util.sid = sid;
    Util.cookie = smid;
    //如果开启了自动登录，则判断当前登录状态

    String autoLogin = await Util.getStorage("auto_login");
    if (autoLogin == "1") {
      var checkLogin = await Api.shareList();
      if (!checkLogin['success']) {
        //如果登录失效，尝试重新登录
        String account = await Util.getStorage("account");
        String password = await Util.getStorage("password");
        var loginRes = await Api.login(host: Util.baseUrl, account: account, password: password);
        if (loginRes['success'] == true) {
          //重新登录成功
          Util.setStorage("sid", loginRes['data']['sid']);
          Util.sid = loginRes['data']['sid'];
          needLogin = false;
        } else {
          needLogin = true;
        }
      } else {
        needLogin = false;
      }
    }
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DarkModeProvider(darkMode)),
      ],
      child: MyApp(needLogin),
    ),
  );
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }
}

class AppAnalysis extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute != null && route != null) {
      if (previousRoute.settings.name != null) {
        UmengAnalyticsPlugin.pageEnd(previousRoute.settings.name);
      }

      if (route.settings.name != null) {
        UmengAnalyticsPlugin.pageStart(route.settings.name);
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route != null && previousRoute != null) {
      if (route.settings.name != null) {
        UmengAnalyticsPlugin.pageEnd(route.settings.name);
      }

      if (previousRoute.settings.name != null) {
        UmengAnalyticsPlugin.pageStart(previousRoute.settings.name);
      }
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    if (oldRoute != null && newRoute != null) {
      if (oldRoute.settings.name != null) {
        UmengAnalyticsPlugin.pageEnd(oldRoute.settings.name);
      }

      if (newRoute.settings.name != null) {
        UmengAnalyticsPlugin.pageStart(newRoute.settings.name);
      }
    }
  }
}

class MyApp extends StatefulWidget {
  final bool needLogin;
  MyApp(this.needLogin);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeProvider>(
      builder: (context, darkModeProvider, _) {
        return OKToast(
          child: darkModeProvider.darkMode == 2
              ? MaterialApp(
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
                  darkTheme: ThemeData.dark().copyWith(
                    scaffoldBackgroundColor: Colors.black,
                    appBarTheme: AppBarTheme(
                      centerTitle: true,
                      elevation: 0,
                      color: Colors.black,
                      iconTheme: IconThemeData(color: Colors.white),
                      actionsIconTheme: IconThemeData(color: Colors.white),
                      textTheme: TextTheme(headline6: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)),
                      brightness: Brightness.dark,
                    ),
                  ),
                  home: widget.needLogin ? Login() : Home(),
                  navigatorObservers: [AppAnalysis()],
                  routes: {
                    "/login": (BuildContext context) => Login(),
                    "/home": (BuildContext context) => Home(),
                  },
                )
              : MaterialApp(
                  title: '群辉助手',
                  debugShowCheckedModeBanner: false,
                  theme: darkModeProvider.darkMode == 0
                      ? ThemeData.light().copyWith(
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
                        )
                      : ThemeData.dark().copyWith(
                          scaffoldBackgroundColor: Colors.black,
                          appBarTheme: AppBarTheme(
                            centerTitle: true,
                            elevation: 0,
                            color: Colors.black,
                            iconTheme: IconThemeData(color: Colors.white),
                            actionsIconTheme: IconThemeData(color: Colors.white),
                            textTheme: TextTheme(headline6: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)),
                            brightness: Brightness.dark,
                          ),
                        ),
                  home: widget.needLogin ? Login() : Home(),
                  // onGenerateRoute: ,
                  navigatorObservers: [AppAnalysis()],
                  routes: {
                    "/login": (BuildContext context) => Login(),
                    "/home": (BuildContext context) => Home(),
                  },
                ),
        );
      },
    );
  }
}
