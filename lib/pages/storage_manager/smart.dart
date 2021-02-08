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
  TabController _tabController;
  bool loading = true;
  Map history;
  Map overview;
  List smartInfo = [];
  List logs = [];
  bool logLoading = true;
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 3 && logLoading) {
        getLog();
      }
    });
    getData();
    super.initState();
  }

  getLog() async {
    var res = await Api.smartLog(widget.disk['device']);
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
                        child: Text("S.M.A.R.T 状态"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("S.M.A.R.T 检测"),
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
                                          "硬盘重新识别次数",
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
                      Center(
                        child: Text("待开发"),
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
