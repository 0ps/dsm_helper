import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class LogCenter extends StatefulWidget {
  @override
  _LogCenterState createState() => _LogCenterState();
}

class _LogCenterState extends State<LogCenter> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List lastLogs = [];
  List logs = [];
  List histories = [];
  bool loadingRecent = true;
  bool loadingLogs = true;
  bool loadingHistory = true;
  int errorCount = 0;
  int warnCount = 0;
  int infoCount = 0;
  int totalCount = 0;
  @override
  void initState() {
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 1 && loadingLogs) {
          getLogs();
        }
        if (_tabController.index == 2 && loadingHistory) {
          getHistories();
        }
      }
    });
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.lastLog(0, 50);
    if (res['success']) {
      setState(() {
        loadingRecent = false;
        lastLogs = res['data']['logs'];
      });
    }
  }

  getLogs() async {
    var res = await Api.log(0, 1000);
    if (res['success']) {
      setState(() {
        loadingLogs = false;
        logs = res['data']['items'];
        errorCount = res['data']['errorCount'];
        warnCount = res['data']['warnCount'];
        infoCount = res['data']['infoCount'];
        totalCount = res['data']['total'];
      });
    }
  }

  getHistories() async {
    var res = await Api.logHistory();
    if (res['success']) {
      setState(() {
        loadingHistory = false;
        histories = res['data']['items'];
      });
    }
  }

  Widget _buildRecentLogItem(log) {
    return NeuCard(
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Label(log['prio'] == "info" ? "信息" : log['prio'], log['prio'] == "info" ? Colors.green : Colors.red),
                SizedBox(
                  width: 5,
                ),
                Text(
                  log['fac'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "${log['ldate']}${log['ltime']}",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text("${log['msg'].trim()}"),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(log) {
    return NeuCard(
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Label(log['level'] == 0 ? "信息" : "${log['level']}", log['level'] == 0 ? Colors.green : Colors.red),
                SizedBox(
                  width: 5,
                ),
                Text(
                  log['user'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "${log['time']}",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text("${log['event'].trim()}"),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(log) {
    return NeuCard(
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Label(
                    log['level'] == "info"
                        ? "信息"
                        : log['level'] == "warn"
                            ? "警告"
                            : log['level'] == "error"
                                ? "错误"
                                : log['level'],
                    log['level'] == "info"
                        ? Colors.green
                        : log['level'] == "warn"
                            ? Colors.orange
                            : log['level'] == "error"
                                ? Colors.red
                                : Colors.red),
                SizedBox(
                  width: 5,
                ),
                Label(log['logtype'], Colors.lightBlueAccent),
                SizedBox(
                  width: 5,
                ),
                Text(
                  log['who'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "${log['time']}",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text("${log['descr'].trim()}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("日志中心"),
      ),
      body: Column(
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
                  child: Text("日志"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("设置历史记录"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("通知"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("归档设置"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("日志发送"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("接收日志"),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                loadingRecent
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
                          SizedBox(
                            height: 20,
                          ),
                          NeuCard(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.all(20),
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 10,
                            child: Text("上50个日志"),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              itemBuilder: (context, i) {
                                return _buildRecentLogItem(lastLogs[i]);
                              },
                              itemCount: lastLogs.length,
                              separatorBuilder: (context, i) {
                                return SizedBox(
                                  height: 20,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                loadingLogs
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
                          SizedBox(
                            height: 20,
                          ),
                          NeuCard(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.all(20),
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 10,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.lightBlueAccent,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("$infoCount"),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("$warnCount"),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("$errorCount"),
                                Spacer(),
                                Text("共$totalCount项"),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              itemBuilder: (context, i) {
                                return _buildLogItem(logs[i]);
                              },
                              itemCount: logs.length,
                              separatorBuilder: (context, i) {
                                return SizedBox(
                                  height: 20,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                loadingHistory
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
                    : ListView.separated(
                        padding: EdgeInsets.all(20),
                        itemBuilder: (context, i) {
                          return _buildHistoryItem(histories[i]);
                        },
                        itemCount: histories.length,
                        separatorBuilder: (context, i) {
                          return SizedBox(
                            height: 20,
                          );
                        },
                      ),
                Center(
                  child: Text("暂未开发"),
                ),
                Center(
                  child: Text("暂未开发"),
                ),
                Center(
                  child: Text("暂未开发"),
                ),
                Center(
                  child: Text("暂未开发"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
