import 'package:dsm_helper/pages/security_scan/result_card.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/strings.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SecurityScan extends StatefulWidget {
  @override
  _SecurityScanState createState() => _SecurityScanState();
}

class _SecurityScanState extends State<SecurityScan> with SingleTickerProviderStateMixin {
  Map colors = {
    "safe": Colors.green,
    "risk": Colors.red,
    "warning": Colors.orange,
    "info": Colors.orangeAccent,
    "outOfDate": Colors.amber,
  };
  Map texts = {
    "safe": {"title": "良好", "content": "DSM 的安全性良好"},
    "risk": {"title": "有风险", "content": "有安全风险需您注意"},
    "warning": {"title": "警告", "content": "部分安全保护设置未启用"},
    "info": {"title": "信息", "content": "信息"},
    "outOfDate": {"title": "版本过旧", "content": "有软件需更新"},
    "running": {"title": "正在扫描", "content": "正在进行扫描..."},
    "stop": {"title": "正在停止", "content": "停止扫描..."},
    "update": {"title": "正在更新", "content": "正在更新安全数据库..."},
  };
  Map icons = {
    "safe": Icons.check_circle,
    "risk": Icons.info,
    "warning": Icons.info,
    "info": Icons.info,
    "outOfDate": Icons.info,
  };
  Map severities = {
    "risk": 0,
    "danger": 1,
    "warning": 2,
    "outOfDate": 3,
    "info": 4,
  };
  Map status = {
    "running": 0,
    "fail": 1,
    "pass": 2,
  };
  TabController _tabController;
  Map ruleItems = {};
  List rules = [];
  bool ruleUpdating = true;
  Map systemItems = {};
  String lastScanTime = "";
  String startTime = "";
  int sysProgress = 0;
  String sysStatus = "";
  bool loading = true;
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    var rule = await Api.securityRule();
    if (rule['success']) {
      setState(() {
        ruleItems = rule['data']['items'];
        ruleItems.removeWhere((key, value) => value['status'] == "skip");
        rules = ruleItems.values.toList();
        rules.forEach((element) {
          element['severity'] = severities[element['severity']];
          element['status'] = status[element['status']];
        });
        rules.sort((v1, v2) {
          try {
            if (v1['status'] > v2['status']) {
              return 1;
            } else if (v1['status'] < v2['status']) {
              return -1;
            } else {
              if (v1['severity'] > v2['severity']) {
                return 1;
              } else if (v1['severity'] < v2['severity']) {
                return -1;
              } else {
                return 0;
              }
            }
          } catch (e) {
            return 0;
          }
        });
        ruleUpdating = rule['data']['isUpdating'];
      });
    }
    var system = await Api.securitySystem();
    if (system['success']) {
      setState(() {
        loading = false;
        systemItems = system['data']['items'];
        lastScanTime = system['data']['lastScanTime'];
        startTime = system['data']['startTime'];
        sysProgress = system['data']['sysProgress'];
        sysStatus = system['data']['sysStatus'];
      });
    }
  }

  String getTitle(String strId, int status) {
    if (webManagerStrings['rules']["${strId}_desc_${status == 2 ? "good" : status == 0 ? "running" : "bad"}"] !=
        null) {
      return webManagerStrings['rules']["${strId}_desc_${status == 2 ? "good" : status == 0 ? "running" : "bad"}"];
    } else {
      if (Util.strings['SYNO.SDS.SecurityScan.Instance'] != null && Util.strings['SYNO.SDS.SecurityScan.Instance']['rules'] != null) {
        return (Util.strings['SYNO.SDS.SecurityScan.Instance']['rules']["${strId}_desc_${status == 2 ? "good" : status == 0 ? "running" : "bad"}"] ??
            "$strId");
      } else {
        return strId;
      }
    }
  }

  List<Widget> _buildItemList() {
    List<Widget> list = [];

    rules.forEach((value) {
      value['strId'] = value['strId'].replaceAll("_v2", "");
      list.add(NeuCard(
        margin: EdgeInsets.only(bottom: 20),
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        curveType: CurveType.flat,
        bevel: 20,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Text(getTitle(value['strId'], value['status'])),
              ),
              value['status'] == 2
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : value['status'] == 0
                      ? CupertinoActivityIndicator()
                      : Icon(
                          Icons.info,
                          color: Colors.red,
                        ),
            ],
          ),
        ),
      ));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("安全顾问"),
      ),
      body: loading
          ? Center(
              child: NeuCard(
                padding: EdgeInsets.all(50),
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: CupertinoActivityIndicator(
                  radius: 14,
                ),
              ),
            )
          : Column(
              children: [
                NeuCard(
                  width: double.infinity,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  curveType: CurveType.flat,
                  bevel: 10,
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicator: BubbleTabIndicator(
                      indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                      shadowColor: Util.getAdjustColor(Theme.of(context).scaffoldBackgroundColor, -20),
                    ),
                    tabs: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("总览"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("结果"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("登录分析"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("高级设置"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView(
                        padding: EdgeInsets.all(20),
                        children: [
                          NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  sysStatus == "running"
                                      ? CircularPercentIndicator(
                                          radius: 80,
                                          // progressColor: Colors.lightBlueAccent,
                                          animation: true,
                                          linearGradient: LinearGradient(
                                            colors: sysProgress < 90
                                                ? [
                                                    Colors.blue,
                                                    Colors.blueAccent,
                                                  ]
                                                : [
                                                    Colors.green,
                                                    Colors.greenAccent,
                                                  ],
                                          ),
                                          animateFromLastPercent: true,
                                          circularStrokeCap: CircularStrokeCap.round,
                                          lineWidth: 12,
                                          backgroundColor: Colors.black12,
                                          percent: sysProgress / 100,
                                          center: Text(
                                            "$sysProgress%",
                                            style: TextStyle(color: sysProgress < 90 ? Colors.blue : Colors.red, fontSize: 22),
                                          ),
                                        )
                                      : Icon(
                                          icons[sysStatus],
                                          color: colors[sysStatus],
                                          size: 70,
                                        ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        texts[sysStatus] != null ? texts[sysStatus]['title'] : "未知状态",
                                        style: TextStyle(fontSize: 20, color: colors[sysStatus]),
                                      ),
                                      Text(
                                        texts[sysStatus] != null ? texts[sysStatus]['content'] : "未知状态",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      if (lastScanTime.isNotBlank)
                                        Text(
                                          "上次扫描：${DateTime.fromMillisecondsSinceEpoch(int.parse(lastScanTime) * 1000).timeAgo}",
                                          style: TextStyle(fontSize: 14),
                                        )
                                      else
                                        Text(
                                          "已运行：${Util.timeRemaining(DateTime.now().secondsSinceEpoch - int.parse(startTime))}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ResultCard(systemItems['malware']),
                          ResultCard(systemItems['systemCheck']),
                          ResultCard(systemItems['userInfo']),
                          ResultCard(systemItems['network']),
                          ResultCard(systemItems['update']),
                        ],
                      ),
                      ListView(
                        padding: EdgeInsets.all(20),
                        children: _buildItemList(),
                      ),
                      Center(
                        child: Text("待开发"),
                      ),
                      Center(
                        child: Text("待开发"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
