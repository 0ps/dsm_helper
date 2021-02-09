import 'dart:async';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Smart extends StatefulWidget {
  final Map disk;
  Smart(this.disk);
  @override
  _SmartState createState() => _SmartState();
}

class _SmartState extends State<Smart> with SingleTickerProviderStateMixin {
  Timer timer;
  TabController _tabController;
  bool loading = true;
  Map history;
  Map overview;
  List smartInfo = [];
  List logs = [];
  bool logLoading = true;

  bool testing = false;
  String remain = "";
  String quickLast = "";
  String extendLast = "";
  List testInfo = [];
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 3 && logLoading) {
        getLog();
      }
    });
    getData();
    getSmartLog();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  doSmartTest(String type) async {
    setState(() {
      testing = true;
    });
    if (timer != null) {
      return;
    }
    var res = await Api.doSmartTest(widget.disk['device'], type);
    if (res['success']) {
      getSmartLog();
      timer = Timer.periodic(Duration(seconds: 4), (timer) {
        getSmartLog();
      });
    } else {
      Util.toast("执行检测失败，代码${res['error']['code']}");
      setState(() {
        testing = false;
      });
    }
  }

  getLog() async {
    var res = await Api.diskTestLog(widget.disk['device']);
    if (res['success']) {
      setState(() {
        logLoading = false;
        logs = res['data']['testLog'];
      });
    }
  }

  getData() async {
    var res = await Api.smart(widget.disk['device']);
    if (res['success']) {
      setState(() {
        loading = false;
        history = res['data']['healthInfo']['history'];
        overview = res['data']['healthInfo']['overview'];
        smartInfo = res['data']['healthInfo']['smartInfo'];
      });
    } else {
      Util.toast("获取失败");
    }
  }

  getSmartLog() async {
    var res = await Api.smartTestLog(widget.disk['device']);
    print(res);
    if (res['success']) {
      setState(() {
        quickLast = res['data']['quick_last'];
        extendLast = res['data']['extend_last'];
        testInfo = res['data']['testInfo'];
        testing = res['data']['testInfo'].last['testing'];
        remain = res['data']['testInfo'].last['remain'];
        if (!testing) {
          timer?.cancel();
        }
      });
    }
  }

  Widget _buildSmartItem(smart) {
    return NeuCard(
      padding: EdgeInsets.all(20),
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Column(
        children: [
          Row(
            children: [
              Label(smart['id'], Colors.lightBlueAccent),
              SizedBox(
                width: 5,
              ),
              Label(
                smart['status'],
                smart['status'] == "OK" ? Colors.green : Colors.red,
                fill: true,
              ),
              SizedBox(
                width: 5,
              ),
              Text(smart['name']),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "现值：", style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: "${smart['current']}"),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "最差值：", style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: "${smart['worst']}"),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "临界值：", style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: "${smart['threshold']}"),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "原始资料：", style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: "${smart['raw']}"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(log) {
    return NeuCard(
      padding: EdgeInsets.all(20),
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${log['time']}"),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Label(
                log['result'] == "smart_complete" ? "正常" : log['result'],
                log['result'] == "smart_complete" ? Colors.green : Colors.red,
                fill: true,
              ),
              SizedBox(
                width: 10,
              ),
              Text("${log['test_type'] == "quick" ? "S.M.A.R.T. 快速测试" : log['test_type']}"),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("${widget.disk['name']} 状况信息"),
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
                        child: Text("概述"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("S.M.A.R.T. 检测"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("S.M.A.R.T. 状态"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("历史记录"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView(
                        children: [
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            curveType: CurveType.flat,
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: Icon(
                                      widget.disk['overview_status'] == "normal" ? Icons.check : Icons.clear,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    radius: 30,
                                    backgroundColor: widget.disk['overview_status'] == "normal" ? Colors.green : Colors.red,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${widget.disk['overview_status'] == "normal" ? "正常" : widget.disk['overview_status']}",
                                          style: TextStyle(fontSize: 20, color: widget.disk['overview_status'] == "normal" ? Colors.green : Colors.red),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text("${widget.disk['overview_status'] == "normal" ? "此硬盘的运行状况正常" : widget.disk['overview_status']}"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            curveType: CurveType.flat,
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          "温度",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text("${widget.disk['temp']} 摄氏度"),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          "开机时间",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text("${overview['poweron'] ?? "-"} 小时"),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          "硬盘重新连接次数",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text("${overview['retry']}"),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          "坏扇区数量",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text("${overview['unc']}"),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          "硬盘重新识别次数",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text("${overview['idnf']}"),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          "S.M.A.R.T. 状态",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        "${overview['smart'] == "normal" ? "正常" : overview['smart_status']}",
                                        style: TextStyle(color: overview['smart'] == "normal" ? Colors.green : Colors.red),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      ListView(
                        padding: EdgeInsets.all(20),
                        children: [
                          NeuCard(
                            curveType: CurveType.flat,
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "检测结果",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "上次快速检测结果",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${quickLast.isNotBlank ? quickLast : "暂无快速检测结果"}",
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      if (quickLast.isNotBlank)
                                        Label(
                                          "${testInfo.last['quick_error_before'] == false ? "正常" : "错误"}",
                                          testInfo.last['quick_error_before'] == false ? Colors.green : Colors.red,
                                          fill: true,
                                        ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "上次完整检测结果",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${extendLast.isNotBlank ? extendLast : "暂无完整检测结果"}",
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      if (extendLast.isNotBlank)
                                        Label(
                                          "${testInfo.last['quick_error_before'] == false ? "正常" : "错误"}",
                                          testInfo.last['quick_error_before'] == false ? Colors.green : Colors.red,
                                          fill: true,
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
                          NeuCard(
                            curveType: CurveType.flat,
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "S.M.A.R.T. 测试",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "S.M.A.R.T. 测试是硬盘的内置测试程序，是专为检测机械和电气误差而设计的。",
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  if (testing) ...[
                                    NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text("检测进度：$remain"),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            NeuButton(
                                              onPressed: () async {
                                                doSmartTest("stop");
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.all(5),
                                              bevel: 5,
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: Icon(
                                                  CupertinoIcons.stop_circle,
                                                  color: Color(0xffff9813),
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "快速检测",
                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                  Text("将执行基本诊断测试，以检测机械和电气误差。")
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            NeuButton(
                                              onPressed: () async {
                                                doSmartTest("quick");
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.all(5),
                                              bevel: 5,
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: Icon(
                                                  CupertinoIcons.play_arrow_solid,
                                                  color: Color(0xffff9813),
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "完整检测",
                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                  Text("将扫描整个硬盘以确保更准确的结果。"),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            NeuButton(
                                              onPressed: () async {
                                                doSmartTest("extend");
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.all(5),
                                              bevel: 5,
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: Icon(
                                                  CupertinoIcons.play_arrow_solid,
                                                  color: Color(0xffff9813),
                                                  size: 16,
                                                ),
                                              ),
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
                      ListView.separated(
                        padding: EdgeInsets.all(20),
                        itemBuilder: (context, i) {
                          return _buildSmartItem(smartInfo[i]);
                        },
                        itemCount: smartInfo.length,
                        separatorBuilder: (context, i) {
                          return SizedBox(
                            height: 20,
                          );
                        },
                      ),
                      logLoading
                          ? Center(
                              child: Center(
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
                              ),
                            )
                          : logs.length > 0
                              ? ListView.separated(
                                  padding: EdgeInsets.all(20),
                                  itemBuilder: (context, i) {
                                    return _buildLogItem(logs[i]);
                                  },
                                  separatorBuilder: (context, i) {
                                    return SizedBox(
                                      height: 20,
                                    );
                                  },
                                  itemCount: logs.length)
                              : Center(
                                  child: Text("暂无历史记录"),
                                ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
