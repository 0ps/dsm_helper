import 'dart:io';

import 'package:dsm_helper/pages/common/gesture_password.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class HelperSetting extends StatefulWidget {
  @override
  _HelperSettingState createState() => _HelperSettingState();
}

class _HelperSettingState extends State<HelperSetting> {
  final LocalAuthentication auth = LocalAuthentication();
  bool launchAuth = false;
  bool password = false;
  bool biometrics = false;

  bool canCheckBiometrics = false;

  BiometricType biometricsType = BiometricType.fingerprint;
  @override
  void initState() {
    initAuth();
    super.initState();
  }

  initAuth() async {
    String launchAuthStr = await Util.getStorage("launch_auth");
    String launchAuthPasswordStr = await Util.getStorage("launch_auth_password");
    String launchAuthBiometricsStr = await Util.getStorage("launch_auth_biometrics");
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
    canCheckBiometrics = await auth.canCheckBiometrics;
    setState(() {});
    if (canCheckBiometrics) {
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      if (Platform.isIOS) {
        setState(() {
          if (availableBiometrics.contains(BiometricType.face)) {
            biometricsType = BiometricType.face;
          } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
            biometricsType = BiometricType.fingerprint;
          } else if (availableBiometrics.contains(BiometricType.iris)) {
            biometricsType = BiometricType.iris;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("助手设置"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                Util.vibrateOn = !Util.vibrateOn;
                Util.setStorage("vibrate_on", Util.vibrateOn ? "1" : "0");
                if (Util.vibrateOn) {
                  Util.vibrate(FeedbackType.light);
                }
              });
            },
            child: NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              curveType: Util.vibrateOn ? CurveType.emboss : CurveType.flat,
              bevel: 20,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/vibrate.png",
                          width: 30,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "震动",
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        if (Util.vibrateOn)
                          Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Color(0xffff9813),
                          ),
                      ],
                    ),
                    if (Util.vibrateOn)
                      NeuCard(
                        margin: EdgeInsets.only(top: 20),
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        curveType: CurveType.flat,
                        bevel: 20,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Util.vibrateNormal = !Util.vibrateNormal;
                                    Util.setStorage("vibrate_warning", Util.vibrateNormal ? "1" : "0");
                                    if (Util.vibrateNormal) {
                                      Util.vibrate(FeedbackType.light);
                                    }
                                  });
                                },
                                child: NeuCard(
                                  // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  padding: EdgeInsets.all(20),
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  curveType: Util.vibrateNormal ? CurveType.emboss : CurveType.flat,
                                  bevel: 20,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "基础操作震动",
                                            style: TextStyle(fontSize: 16, height: 1.6),
                                          ),
                                          Spacer(),
                                          if (Util.vibrateNormal)
                                            Icon(
                                              CupertinoIcons.checkmark_alt,
                                              color: Color(0xffff9813),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Util.vibrateWarning = !Util.vibrateWarning;
                                    Util.setStorage("vibrate_warning", Util.vibrateWarning ? "1" : "0");
                                    if (Util.vibrateWarning) {
                                      Util.vibrate(FeedbackType.warning);
                                    }
                                  });
                                },
                                child: NeuCard(
                                  // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  padding: EdgeInsets.all(20),
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  curveType: Util.vibrateWarning ? CurveType.emboss : CurveType.flat,
                                  bevel: 20,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "敏感操作震动",
                                            style: TextStyle(fontSize: 16, height: 1.6),
                                          ),
                                          Spacer(),
                                          if (Util.vibrateWarning)
                                            Icon(
                                              CupertinoIcons.checkmark_alt,
                                              color: Color(0xffff9813),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                launchAuth = !launchAuth;
                Util.setStorage("launch_auth", launchAuth ? "1" : "0");
              });
            },
            child: NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              curveType: launchAuth ? CurveType.emboss : CurveType.flat,
              bevel: 20,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/safe.png",
                          width: 30,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "启动密码",
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        if (launchAuth)
                          Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Color(0xffff9813),
                          ),
                      ],
                    ),
                    if (launchAuth)
                      NeuCard(
                        margin: EdgeInsets.only(top: 20),
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        curveType: CurveType.flat,
                        bevel: 20,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (password) {
                                      setState(() {
                                        password = false;
                                        Util.setStorage("launch_auth_password", "0");
                                        biometrics = false;
                                        Util.setStorage("launch_auth_biometrics", "0");
                                      });
                                    } else {
                                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                        return GesturePasswordPage();
                                      })).then((res) {
                                        if (res != null && res) {
                                          setState(() {
                                            password = true;
                                            Util.setStorage("launch_auth_password", password ? "1" : "0");
                                          });
                                        }
                                      });
                                    }
                                    // password = !password;
                                    // Util.setStorage("launch_password", password ? "1" : "0");
                                  });
                                },
                                child: NeuCard(
                                  // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  padding: EdgeInsets.all(20),
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  curveType: password ? CurveType.emboss : CurveType.flat,
                                  bevel: 20,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "图形密码",
                                            style: TextStyle(fontSize: 16, height: 1.6),
                                          ),
                                          Spacer(),
                                          if (password)
                                            Icon(
                                              CupertinoIcons.checkmark_alt,
                                              color: Color(0xffff9813),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (canCheckBiometrics) ...[
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (biometrics == false) {
                                      if (password == false) {
                                        Util.vibrate(FeedbackType.warning);
                                        Util.toast("请先开启图形密码后再开启指纹");
                                        return;
                                      }
                                      try {
                                        bool didAuthenticate = await auth.authenticateWithBiometrics(
                                          localizedReason: '请触摸指纹传感器',
                                          androidAuthStrings: AndroidAuthMessages(
                                            fingerprintNotRecognized: "系统未设置指纹",
                                            fingerprintRequiredTitle: "请触摸指纹传感器",
                                            signInTitle: "验证指纹",
                                            cancelButton: "取消",
                                            fingerprintHint: "如果验证失败5次请等待30秒后重试",
                                            goToSettingsButton: "设置",
                                            goToSettingsDescription: "点击设置按钮前往系统指纹设置页面",
                                            fingerprintSuccess: "指纹验证成功",
                                          ),
                                          iOSAuthStrings: IOSAuthMessages(
                                            lockOut: "认证失败次数过多，请稍后再试",
                                            goToSettingsButton: "设置",
                                            goToSettingsDescription: "系统未设置${biometricsType == BiometricType.fingerprint ? "指纹" : "Face ID"}，点击设置按钮前往系统设置页面",
                                            cancelButton: "取消",
                                          ),
                                          sensitiveTransaction: false,
                                        );
                                        setState(() {
                                          biometrics = didAuthenticate;
                                          Util.setStorage("launch_auth_biometrics", biometrics ? "1" : "0");
                                        });
                                      } on PlatformException catch (e) {
                                        if (e.code == auth_error.notAvailable) {
                                          Util.toast("生物验证不可用");
                                        } else if (e.code == auth_error.passcodeNotSet) {
                                          Util.toast("系统未设置密码");
                                        } else if (e.code == auth_error.lockedOut) {
                                          Util.toast("认证失败次数过多，请稍后再试");
                                        } else {
                                          Util.toast(e.message);
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        biometrics = false;
                                        Util.setStorage("launch_auth_biometrics", biometrics ? "1" : "0");
                                      });
                                    }

                                    // setState(() {
                                    //   biometrics = !biometrics;
                                    //   Util.setStorage("launch_biometrics", biometrics ? "1" : "0");
                                    // });
                                  },
                                  child: NeuCard(
                                    // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    padding: EdgeInsets.all(20),
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    curveType: biometrics ? CurveType.emboss : CurveType.flat,
                                    bevel: 20,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              biometricsType == BiometricType.fingerprint
                                                  ? "指纹验证"
                                                  : biometricsType == BiometricType.face
                                                      ? "Face ID"
                                                      : "虹膜验证",
                                              style: TextStyle(fontSize: 16, height: 1.6),
                                            ),
                                            Spacer(),
                                            if (biometrics)
                                              Icon(
                                                CupertinoIcons.checkmark_alt,
                                                color: Color(0xffff9813),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
