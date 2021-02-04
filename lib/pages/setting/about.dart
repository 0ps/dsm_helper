import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:dsm_helper/pages/setting/open_source.dart';
import 'package:dsm_helper/pages/setting/reward.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool checking = false;
  PackageInfo packageInfo;
  String account = "challengerv";
  @override
  void initState() {
    getInfo();
    super.initState();
  }

  getInfo() async {
    Util.getStorage("account").then((value) => setState(() => account = value));
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "关于${Util.appName}",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NeuCard(
                      bevel: 20,
                      curveType: CurveType.flat,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(
                          "assets/logo.png",
                        ),
                        radius: 40,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: [
                        Text(
                          "${Platform.isIOS ? "NAS助手" : "群晖助手"}",
                          style: TextStyle(fontSize: 32),
                        ),
                        if (packageInfo != null)
                          Text(
                            "v${packageInfo.version} build:${packageInfo.buildNumber}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                NeuCard(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  curveType: CurveType.flat,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/qq.png",
                          width: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "QQ群：240557031",
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        NeuButton(
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          onPressed: () {
                            if (Platform.isAndroid) {
                              AndroidIntent intent = AndroidIntent(
                                action: 'action_view',
                                data:
                                    'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D4woOsiYfPZO4lZ08fX4el43n926mj1r5',
                                arguments: {},
                                // data: 'https://qm.qq.com/cgi-bin/qm/qr?k=Gf20e3f1FXrlIUfgp9IwzMnqPuFKRwVK&jump_from=webapi',
                                // type: "video/*",
                              );

                              intent.launch();
                            } else {
                              launch(
                                  'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D4woOsiYfPZO4lZ08fX4el43n926mj1r5');
                            }
                          },
                          child: Text("加群"),
                        ),
                      ],
                    ),
                  ),
                ),
                if (account != "challengerv") ...[
                  SizedBox(
                    height: 20,
                  ),
                  NeuCard(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: CurveType.flat,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/icons/wechat.png",
                            width: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "公众号：群晖助手",
                            style: TextStyle(fontSize: 16),
                          ),
                          Spacer(),
                          NeuButton(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            onPressed: () {
                              ClipboardData data = new ClipboardData(text: "群晖助手");
                              Clipboard.setData(data);
                              Util.toast("已复制到剪贴板");
                            },
                            child: Text("复制"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  NeuCard(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: CurveType.flat,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/icons/coffee.png",
                                width: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "给作者买杯咖啡",
                                style: TextStyle(fontSize: 16),
                              ),
                              Spacer(),
                              NeuButton(
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                onPressed: () {
                                  Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) {
                                      return Reward();
                                    },
                                    settings: RouteSettings(name: "reward"),
                                  ));
                                },
                                child: Text("打赏名单"),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              curveType: CurveType.flat,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  "assets/pay_qr.png",
                                  width: MediaQuery.of(context).size.width / 2 - 50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  height: 20,
                ),
                NeuCard(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  curveType: CurveType.flat,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/gitee.png",
                          width: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${Util.appName}开源地址",
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        NeuButton(
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          onPressed: () {
                            if (Platform.isAndroid) {
                              AndroidIntent intent = AndroidIntent(
                                action: 'action_view',
                                data: 'https://gitee.com/challengerV/dsm_helper',
                                arguments: {},
                              );

                              intent.launch();
                            } else {
                              launch('https://gitee.com/challengerV/dsm_helper');
                            }
                          },
                          child: Text("查看"),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                NeuCard(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  curveType: CurveType.flat,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        FlutterLogo(
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Powered by Flutter",
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        NeuButton(
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          onPressed: () {
                            if (Platform.isAndroid) {
                              AndroidIntent intent = AndroidIntent(
                                action: 'action_view',
                                data: 'https://flutter.dev',
                                arguments: {},
                              );

                              intent.launch();
                            } else {
                              launch('https://flutter.dev');
                            }
                          },
                          child: Text("官网"),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                NeuCard(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  curveType: CurveType.flat,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/pub.png",
                          width: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "开源插件",
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        NeuButton(
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) {
                                  return OpenSource();
                                },
                                settings: RouteSettings(name: "open_source")));
                          },
                          child: Text("详情"),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          if (Platform.isAndroid)
            Padding(
              padding: EdgeInsets.all(20),
              child: NeuButton(
                onPressed: () async {
                  if (checking) {
                    return;
                  }
                  setState(() {
                    checking = true;
                  });
                  await Util.checkUpdate(true, context);
                  setState(() {
                    checking = false;
                  });
                },
                // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: checking
                    ? Center(
                        child: CupertinoActivityIndicator(
                          radius: 13,
                        ),
                      )
                    : Text(
                        "检查更新",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
