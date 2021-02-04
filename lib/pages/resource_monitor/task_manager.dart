import 'dart:async';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/strings.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class TaskManager extends StatefulWidget {
  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List processes = [];
  List services = [];
  Timer timer;
  bool loading = true;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    getData();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getData();
    });
    super.initState();
  }

  getData() async {
    var process = await Api.process();
    var group = await Api.processGroup();
    if (process['success']) {
      setState(() {
        loading = false;
        processes = process['data']['process'];
        services = group['data']['services'];
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _buildServiceItem(service) {
    String title = "";
    List<String> titles = service['display_name'].split(":");
    //判断是否在string内
    if (titles.length > 1) {
      if (webManagerStrings[titles[0]] != null && webManagerStrings[titles[0]][titles[1]] != null) {
        if (webManagerStrings[titles[0]][titles[1]] != null) {
          title = webManagerStrings[titles[0]][titles[1]];
        }
      } else if (Util.strings[service['display_name']][titles[0]] != null && Util.strings[service['display_name']][titles[0]][titles[1]] != null) {
        title = Util.strings[service['display_name']][titles[0]][titles[1]];
      } else if (Util.strings[service['display_name']] != null && Util.strings[service['display_name']]['common'] != null && Util.strings[service['display_name']]['common']['displayname'] != null) {
        title = Util.strings[service['display_name']]['common']['displayname'];
      }
    } else {
      title = service['display_name'];
    }

    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      curveType: CurveType.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16),
          ),
          // SizedBox(
          //   height: 10,
          // ),
        ],
      ),
    );
  }

  Widget _buildProcessItem(process) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      curveType: CurveType.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${process['command']}",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              process['status'] == "R"
                  ? Label("运行中", Colors.green)
                  : process['status'] == "S"
                      ? Label("睡眠中", Colors.grey)
                      : Label(process['status'], Colors.red),
              SizedBox(
                width: 10,
              ),
              Text("CPU:${(process['cpu'] / 10).toStringAsFixed(1)}%"),
              SizedBox(
                width: 10,
              ),
              Text("PID:${process['pid']}"),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(child: Text("私有内存：${Util.formatSize(process['mem'] * 97, fixed: 1)}")),
              Expanded(child: Text("共享内存：${Util.formatSize(process['mem_shared'] * 1024, fixed: 2)}")),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("任务管理器"),
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
                TabBar(
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
                        child: Text("服务"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("进程"),
                      ),
                    ]),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemBuilder: (context, i) {
                          return _buildServiceItem(services[i]);
                        },
                        itemCount: services.length,
                      ),
                      ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemBuilder: (context, i) {
                          return _buildProcessItem(processes[i]);
                        },
                        itemCount: processes.length,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
