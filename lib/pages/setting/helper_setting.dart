import 'dart:io';

import 'package:dsm_helper/pages/common/gesture_password.dart';
import 'package:dsm_helper/pages/setting/about.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
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
        leading: AppBackButton(context),
        title: Text("????????????"),
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
                          "??????",
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
                                            "??????????????????",
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
                                            "??????????????????",
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
                          "????????????",
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
                                            "????????????",
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
                                        Util.toast("??????????????????????????????????????????");
                                        return;
                                      }
                                      try {
                                        bool didAuthenticate = await auth.authenticate(
                                          biometricOnly: true,
                                          localizedReason: '????????????????????????',
                                          androidAuthStrings: AndroidAuthMessages(
                                            biometricNotRecognized: "?????????????????????",
                                            biometricRequiredTitle: "????????????????????????",
                                            signInTitle: "????????????",
                                            cancelButton: "??????",
                                            biometricHint: "??????????????????5????????????30????????????",
                                            goToSettingsButton: "??????",
                                            goToSettingsDescription: "????????????????????????????????????????????????",
                                            biometricSuccess: "??????????????????",
                                          ),
                                          iOSAuthStrings: IOSAuthMessages(
                                            lockOut: "??????????????????????????????????????????",
                                            goToSettingsButton: "??????",
                                            goToSettingsDescription: "???????????????${biometricsType == BiometricType.fingerprint ? "??????" : "Face ID"}?????????????????????????????????????????????",
                                            cancelButton: "??????",
                                          ),
                                          sensitiveTransaction: false,
                                        );
                                        setState(() {
                                          biometrics = didAuthenticate;
                                          Util.setStorage("launch_auth_biometrics", biometrics ? "1" : "0");
                                        });
                                      } on PlatformException catch (e) {
                                        if (e.code == auth_error.notAvailable) {
                                          Util.toast("?????????????????????");
                                        } else if (e.code == auth_error.passcodeNotSet) {
                                          Util.toast("?????????????????????");
                                        } else if (e.code == auth_error.lockedOut) {
                                          Util.toast("??????????????????????????????????????????");
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
                                                  ? "????????????"
                                                  : biometricsType == BiometricType.face
                                                      ? "Face ID"
                                                      : "????????????",
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
          SizedBox(
            height: 20,
          ),
          NeuButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) {
                    return About();
                  },
                  settings: RouteSettings(name: "about")));
            },
            // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.all(20),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            bevel: 20,
            child: Row(
              children: [
                Image.asset(
                  "assets/icons/info_liner.png",
                  width: 25,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "??????${Util.appName}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // NeuButton(
          //   onPressed: () {
          //     Navigator.of(context).push(CupertinoPageRoute(
          //         builder: (context) {
          //           return Full();
          //         },
          //         settings: RouteSettings(name: "full")));
          //   },
          //   // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //   padding: EdgeInsets.all(20),
          //   decoration: NeumorphicDecoration(
          //     color: Theme.of(context).scaffoldBackgroundColor,
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   bevel: 20,
          //   child: Row(
          //     children: [
          //       Image.asset(
          //         "assets/icons/unzip.png",
          //         width: 25,
          //       ),
          //       SizedBox(
          //         width: 8,
          //       ),
          //       Text(
          //         "???????????????",
          //         style: TextStyle(fontSize: 16),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
