import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

class HelperSetting extends StatefulWidget {
  @override
  _HelperSettingState createState() => _HelperSettingState();
}

class _HelperSettingState extends State<HelperSetting> {
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
                          width: 40,
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
        ],
      ),
    );
  }
}
