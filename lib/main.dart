import 'dart:io';
import 'package:dsm_helper/pages/home.dart';
import 'package:dsm_helper/pages/login/auth_page.dart';
import 'package:dsm_helper/pages/login/login.dart';
import 'package:dsm_helper/pages/provider/shortcut.dart';
import 'package:dsm_helper/pages/provider/wallpaper.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/provider/dark_mode.dart';

void main() async {
  HttpClient client = ExtendedNetworkImageProvider.httpClient as HttpClient;
  client.badCertificateCallback = (X509Certificate cert, String host, int port) {
    return true;
  };

  // print(HttpClientHelper.httpClient.)
  // (HttpClientHelper as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
  //   client.badCertificateCallback = (X509Certificate cert, String host, int port) {
  //     return true;
  //   };
  // };
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: false);
  await UmengAnalyticsPlugin.init(
    androidKey: '5ffe477d6a2a470e8f76809c',
    iosKey: '5ffe47cb6a2a470e8f7680a2',
  );
  Util.downloadSavePath = await Util.getStorage("download_save_path") ?? "/storage/emulated/0/dsm_helper/Download";
  Util.getStorage("download_wifi_only").then((value) {
    if (value != null) {
      Util.downloadWifiOnly = value == "1";
    } else {
      Util.downloadWifiOnly = true;
    }
  });
  //判断是否需要启动密码
  bool launchAuth = false;
  bool password = false;
  bool biometrics = false;
  bool showShortcuts = true;
  bool showWallpaper = true;
  String launchAuthStr = await Util.getStorage("launch_auth");
  String launchAuthPasswordStr = await Util.getStorage("launch_auth_password");
  String launchAuthBiometricsStr = await Util.getStorage("launch_auth_biometrics");

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Util.appName = packageInfo.appName;
  if (launchAuthStr != null) {
    launchAuth = launchAuthStr == "1";
  } else {
    launchAuth = false;
  }
  if (launchAuthPasswordStr != null) {
    password = launchAuthPasswordStr == "1";
  } else {
    password = false;
  }
  if (launchAuthBiometricsStr != null) {
    biometrics = launchAuthBiometricsStr == "1";
  } else {
    biometrics = false;
  }

  bool authPage = launchAuth && (password || biometrics);

  //暗色模式
  String darkModeStr = await Util.getStorage("dark_mode");
  int darkMode = 2;
  if (darkModeStr.isNotBlank) {
    darkMode = int.parse(darkModeStr);
  }

  //震动开关
  String vibrateOn = await Util.getStorage("vibrate_on");
  String vibrateNormal = await Util.getStorage("vibrate_normal");
  String vibrateWarning = await Util.getStorage("vibrate_warning");
  String showShortcutsStr = await Util.getStorage("show_shortcut");
  if (showShortcutsStr.isNotBlank) {
    showShortcuts = showShortcutsStr == "1";
  }
  String showWallpaperStr = await Util.getStorage("show_wallpaper");
  if (showWallpaperStr.isNotBlank) {
    showWallpaper = showWallpaperStr == "1";
  }
  if (vibrateOn.isNotBlank) {
    Util.vibrateOn = vibrateOn == "1";
  } else {
    Util.vibrateOn = true;
  }
  if (vibrateNormal.isNotBlank) {
    Util.vibrateNormal = vibrateNormal == "1";
  } else {
    Util.vibrateNormal = true;
  }
  if (vibrateWarning.isNotBlank) {
    Util.vibrateWarning = vibrateWarning == "1";
  } else {
    Util.vibrateWarning = true;
  }
  String checkSsl = await Util.getStorage("check_ssl");
  if (checkSsl.isNotBlank) {
    Util.checkSsl = checkSsl == "1";
  } else {
    Util.checkSsl = true;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DarkModeProvider(darkMode)),
        ChangeNotifierProvider.value(value: ShortcutProvider(showShortcuts)),
        ChangeNotifierProvider.value(value: WallpaperProvider(showWallpaper)),
      ],
      child: MyApp(authPage),
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
  final bool authPage;
  MyApp(this.authPage);

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
    ThemeData darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        bodyText2: TextStyle(
          fontSize: 15.0,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
      accentColor: Color(0xff888888),
      iconTheme: IconThemeData(color: Colors.white.withOpacity(0.5)),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        color: Colors.black,
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.5)),
        actionsIconTheme: IconThemeData(color: Colors.white.withOpacity(0.5)),
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 20.0, color: Colors.white.withOpacity(0.5)),
        ),
        brightness: Brightness.dark,
      ),
    );
    ThemeData lightTheme = ThemeData.light().copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        color: Color(0xFFF4F4F4),
        iconTheme: IconThemeData(color: Colors.black),
        actionsIconTheme: IconThemeData(color: Colors.black),
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 20.0, color: Colors.black),
        ),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Color(0xFFF4F4F4),
    );
    return Consumer<DarkModeProvider>(
      builder: (context, darkModeProvider, _) {
        return OKToast(
          child: darkModeProvider.darkMode == 2
              ? MaterialApp(
                  title: '${Util.appName}',
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  localizationsDelegates: [
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: [
                    const Locale('zh', 'CN'),
                  ],
                  home: widget.authPage ? AuthPage() : Login(),
                  navigatorObservers: [AppAnalysis()],
                  routes: {
                    "/login": (BuildContext context) => Login(),
                    "/home": (BuildContext context) => Home(),
                  },
                )
              : MaterialApp(
                  title: '${Util.appName}',
                  debugShowCheckedModeBanner: false,
                  theme: darkModeProvider.darkMode == 0 ? lightTheme : darkTheme,
                  localizationsDelegates: [
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: [
                    const Locale('zh', 'CN'),
                  ],
                  home: widget.authPage ? AuthPage() : Login(),
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
