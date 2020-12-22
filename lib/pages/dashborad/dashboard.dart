import 'dart:async';
import 'dart:math';

import 'package:dsm_helper/pages/dashborad/notify.dart';
import 'package:dsm_helper/pages/system/info.dart';
import 'package:dsm_helper/util/badge.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class Dashboard extends StatefulWidget {
  Dashboard({key}) : super(key: key);
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer timer;
  Map utilization;
  List volumes = [];
  List disks = [];
  List connectedUsers = [];
  List interfaces = [];
  List networks = [];
  List ssdCaches = [];
  List tasks = [];
  List latestLog = [];
  List notifies = [];
  List widgets = [];
  List applications = [];
  Map strings;
  Map appNotify;
  Map system;
  bool loading = true;
  bool success = true;
  String hostname = "获取中";
  int maxNetworkSpeed = 0;
  Map volWarnings;
  String msg = "";
  @override
  void initState() {
    getData();
    getInfo();
    super.initState();
  }

  bool get isDrawerOpen {
    return _scaffoldKey.currentState.isDrawerOpen;
  }

  closeDrawer() {
    if (_scaffoldKey.currentState.isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }

  getInfo() async {
    // var res = await Api.info();
    // if (res['success'] != null && res['success'] == false) {
    //   // print(res);
    // } else {
    //   if (mounted) {
    //     setState(() {
    //       interfaces = res['interfaces'];
    //       volWarnings = res['vol_warnings'];
    //     });
    //   } else {
    //     if (timer != null) {
    //       timer.cancel();
    //       timer = null;
    //     }
    //   }
    // }
    var init = await Api.initData();
    if (init['success']) {
      setState(() {
        if (init['data']['UserSettings'] != null) {
          if (init['data']['UserSettings']['SYNO.SDS._Widget.Instance'] != null) {
            widgets = init['data']['UserSettings']['SYNO.SDS._Widget.Instance']['modulelist'];
          }
          print(init['data']['UserSettings']['Desktop']);
          applications = init['data']['UserSettings']['Desktop']['appview_order'] ?? init['data']['UserSettings']['Desktop']['valid_appview_order'];
          print("applications");
          print(applications);
        }
        if (init['data']['Session'] != null) {
          hostname = init['data']['Session']['hostname'];
        }
        if (init['data']['Strings'] != null) {
          strings = init['data']['Strings'];
        }
      });
    }
  }

  double get chartInterval {
    if (maxNetworkSpeed < pow(1024, 2)) {
      return 100 * 1024.0;
    } else if (maxNetworkSpeed < pow(1024, 2) * 5) {
      return 1.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 10) {
      return 2.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 50) {
      return 10.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 100) {
      return 20.0 * pow(1024, 2);
    } else {
      return 50.0 * pow(1024, 2);
    }
  }

  String chartTitle(double v) {
    if (maxNetworkSpeed < pow(1024, 2)) {
      v = v / 1024;
      return (v.floor() * 100).toString();
    } else {
      v = v / pow(1024, 2);
      return (v.floor()).toString() + "M";
    }
  }

  getData() async {
    if (!mounted) {
      if (timer != null) {
        timer.cancel();
        timer = null;
      }
      return;
    }
    var res = await Api.systemInfo();
    // print(res);
    setState(() {
      if (loading) {
        success = res['success'];
      }
      loading = false;
    });
    if (res['success']) {
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.Core.System.Utilization":
              setState(() {
                utilization = item['data'];
                // print(utilization);
                if (networks.length > 20) {
                  networks.removeAt(0);
                }
                networks.add(item['data']['network']);
                int tx = int.parse("${item['data']['network'][0]['tx']}");
                int rx = int.parse("${item['data']['network'][0]['rx']}");
                num maxSpeed = max(tx, rx);
                if (maxSpeed > maxNetworkSpeed) {
                  maxNetworkSpeed = maxSpeed;
                }
              });
              break;
            case "SYNO.Core.System":
              setState(() {
                system = item['data'];
              });
              break;
            case "SYNO.Core.CurrentConnection":
              setState(() {
                connectedUsers = item['data']['items'];
              });
              break;
            case "SYNO.Storage.CGI.Storage":
              setState(() {
                ssdCaches = item['data']['ssdCaches'];
                volumes = item['data']['volumes'];
                disks = item['data']['disks'];

                // print(disks);
              });
              break;
            case 'SYNO.Core.TaskScheduler':
              setState(() {
                tasks = item['data']['tasks'];
              });
              break;
            case 'SYNO.Core.SyslogClient.Status':
              setState(() {
                latestLog = item['data']['logs'];
              });
              break;
            case "SYNO.Core.DSMNotify":
              setState(() {
                notifies = item['data']['items'];
              });
              break;
            case "SYNO.Core.AppNotify":
              setState(() {
                appNotify = item['data'];
              });
              break;
          }
        }

        // else if(item['api'] == ""){
        //
        // }
      });
      if (timer == null) {
        timer = Timer.periodic(Duration(seconds: 10), (timer) {
          getData();
        });
      }
    } else {
      setState(() {
        msg = res['msg'] ?? "加载失败，code:${res['error']['code']}";
      });
      if (timer != null) {
        timer.cancel();
        timer = null;
      }
    }
  }

  Widget _buildWidgetItem(widget) {
    if (widget == "SYNO.SDS.SystemInfoApp.SystemHealthWidget") {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return SystemInfo(0, system, volumes, disks);
          }));
        },
        child: NeuCard(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          bevel: 20,
          curveType: CurveType.flat,
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/icons/info.png",
                    width: 26,
                    height: 26,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "系统状态",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              if (system != null && system['model'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Row(
                    children: [
                      Text("产品型号："),
                      Text("${system['model']}"),
                    ],
                  ),
                ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text("系统名称："),
                  Text("$hostname"),
                ],
              ),
              if (system != null && system['sys_temp'] != null && system['temperature_warning'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Row(
                    children: [
                      Text("散热状态："),
                      Text(
                        "${system['sys_temp']}℃ ${system['temperature_warning'] == null ? (system['sys_temp'] > 80 ? "警告" : "正常") : (system['temperature_warning'] ? "警告" : "正常")}",
                        style: TextStyle(color: system['temperature_warning'] == null ? (system['sys_temp'] > 80 ? Colors.red : Colors.green) : (system['temperature_warning'] ? Colors.red : Colors.green)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              if (system != null && system['up_time'] != null && system['up_time'] != "")
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Row(
                    children: [
                      Text("运行时间："),
                      Text("${Util.parseOpTime(system['up_time'])}"),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.ConnectionLogWidget" && connectedUsers.length > 0) {
      return NeuCard(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        bevel: 20,
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/user.png",
                    width: 26,
                    height: 26,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "登录用户",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ...connectedUsers.map(_buildUserItem).toList(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    } else if (widget == "SYNO.SDS.TaskScheduler.TaskSchedulerWidget" && tasks.length > 0) {
      return NeuCard(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        bevel: 20,
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/task.png",
                    width: 26,
                    height: 26,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "计划任务",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ...tasks.map(_buildTaskItem).toList(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.RecentLogWidget" && latestLog.length > 0) {
      return NeuCard(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        bevel: 20,
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/log.png",
                    width: 26,
                    height: 26,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "最新日志",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 300,
              child: CupertinoScrollbar(
                child: ListView.builder(
                  itemBuilder: (context, i) {
                    return _buildLogItem(latestLog[i]);
                  },
                  itemCount: latestLog.length,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    } else if (widget == "SYNO.SDS.ResourceMonitor.Widget" && utilization != null) {
      return NeuCard(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        bevel: 20,
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/resources.png",
                    width: 26,
                    height: 26,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "资源监控",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text("CPU："),
                  ),
                  Expanded(
                    child: NeuCard(
                      curveType: CurveType.flat,
                      bevel: 10,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FAProgressBar(
                        backgroundColor: Colors.transparent,
                        changeColorValue: 90,
                        changeProgressColor: Colors.red,
                        progressColor: Colors.blue,
                        currentValue: utilization['cpu']['user_load'] + utilization['cpu']['system_load'] + utilization['cpu']['other_load'],
                        displayText: '%',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(width: 50, child: Text("RAM：")),
                  Expanded(
                    child: NeuCard(
                      curveType: CurveType.flat,
                      bevel: 10,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FAProgressBar(
                        backgroundColor: Colors.transparent,
                        changeColorValue: 90,
                        changeProgressColor: Colors.red,
                        progressColor: Colors.blue,
                        currentValue: utilization['memory']['real_usage'],
                        displayText: '%',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(width: 50, child: Text("网络：")),
                  Icon(
                    Icons.upload_sharp,
                    color: Colors.blue,
                  ),
                  Text(
                    Util.formatSize(utilization['network'][0]['tx']) + "/S",
                    style: TextStyle(color: Colors.blue),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Icon(
                    Icons.download_sharp,
                    color: Colors.green,
                  ),
                  Text(
                    Util.formatSize(utilization['network'][0]['rx']) + "/S",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: NeuCard(
                  curveType: CurveType.flat,
                  bevel: 20,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(10),
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.white.withOpacity(0.6),
                            tooltipRoundedRadius: 20,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (items) {
                              return [
                                LineTooltipItem("上传：${Util.formatSize(items[0].y.floor())}", TextStyle(color: Colors.blue)),
                                LineTooltipItem("下载：${Util.formatSize(items[1].y.floor())}", TextStyle(color: Colors.green)),
                              ];
                            }),
                      ),
                      gridData: FlGridData(
                        show: false,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 22,
                        ),
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (value) => const TextStyle(
                            color: Color(0xff67727d),
                            fontSize: 12,
                          ),
                          getTitles: chartTitle,
                          // getTitles: (value) {
                          //   value = value / 1000 / 1000;
                          //   return (value.floor() * 1000).toString();
                          // },
                          reservedSize: 28,
                          interval: chartInterval,
                        ),
                      ),
                      // maxY: 20,
                      borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: networks.map((network) {
                            return FlSpot(networks.indexOf(network).toDouble(), network[0]['tx'].toDouble());
                          }).toList(),
                          isCurved: true,
                          colors: [
                            Colors.blue,
                          ],
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            colors: [Colors.blue.withOpacity(0.2)],
                          ),
                        ),
                        LineChartBarData(
                          spots: networks.map((network) {
                            return FlSpot(networks.indexOf(network).toDouble(), network[0]['rx'].toDouble());
                          }).toList(),
                          isCurved: true,
                          colors: [
                            Colors.green,
                          ],
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            colors: [
                              Colors.green.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.StorageUsageWidget" && volumes != null && volumes.length > 0) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return SystemInfo(2, system, volumes, disks);
          }));
        },
        child: NeuCard(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          curveType: CurveType.flat,
          bevel: 20,
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/icons/pie.png",
                      width: 26,
                      height: 26,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "存储",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              ...volumes.reversed.map(_buildVolumeItem).toList(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      );
    } else if (ssdCaches != null && ssdCaches.length > 0) {
      return NeuCard(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        curveType: CurveType.flat,
        bevel: 20,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/cache.png",
                    width: 26,
                    height: 26,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "缓存",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ...ssdCaches.map(_buildSSDCacheItem).toList(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildUserItem(user) {
    DateTime loginTime = DateTime.parse(user['time'].toString().replaceAll("/", "-"));
    DateTime currentTime = DateTime.now();
    Map timeLong = Util.timeLong(currentTime.difference(loginTime).inSeconds);
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      curveType: CurveType.flat,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${user['who']}",
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              "${user['type']}",
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              "${timeLong['hours'].toString().padLeft(2, "0")}:${timeLong['minutes'].toString().padLeft(2, "0")}:${timeLong['seconds'].toString().padLeft(2, "0")}",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () async {
              if (user['can_be_kicked']) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: Colors.transparent,
                      child: NeuCard(
                        width: double.infinity,
                        padding: EdgeInsets.all(22),
                        bevel: 5,
                        curveType: CurveType.emboss,
                        decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "终止连接",
                              style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              "确认要终止此连接？",
                              style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 22,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      var res = await Api.kickConnection({"who": user['who'], "from": user['from']});
                                      if (res['success']) {
                                        Util.toast("连接已终止");
                                      }
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "终止连接",
                                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "取消",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                Util.toast("此连接无法被终止");
              }
            },
            child: Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(task) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      curveType: CurveType.flat,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${task['name']}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "${task['next_trigger_time']}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(log) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      bevel: 10,
      curveType: CurveType.flat,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${log['msg']}",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeItem(volume) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      child: Row(
        children: [
          NeuCard(
            curveType: CurveType.flat,
            margin: EdgeInsets.all(10),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(80),
              // color: Colors.red,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5),
            bevel: 8,
            child: CircularPercentIndicator(
              radius: 80,
              // progressColor: Colors.lightBlueAccent,
              animation: true,
              linearGradient: LinearGradient(
                colors: int.parse(volume['size']['used']) / int.parse(volume['size']['total']) <= 0.9
                    ? [
                        Colors.blue,
                        Colors.blueAccent,
                      ]
                    : [
                        Colors.red,
                        Colors.orangeAccent,
                      ],
              ),
              animateFromLastPercent: true,
              circularStrokeCap: CircularStrokeCap.round,
              lineWidth: 12,
              backgroundColor: Colors.black12,
              percent: int.parse(volume['size']['used']) / int.parse(volume['size']['total']),
              center: Text(
                "${(int.parse(volume['size']['used']) / int.parse(volume['size']['total']) * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: int.parse(volume['size']['used']) / int.parse(volume['size']['total']) <= 0.9 ? Colors.blue : Colors.red, fontSize: 22),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "${volume['deploy_path'] != null ? volume['deploy_path'].toString().replaceFirst("volume_", "存储空间 ") : volume['id'].toString().replaceFirst("volume_", "存储空间 ")}",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Label(
                      volume['status'] == "normal" ? "正常" : volume['status'],
                      volume['status'] == "normal" ? Colors.green : Colors.red,
                      fill: true,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text("已用：${Util.formatSize(int.parse(volume['size']['used']))}"),
                SizedBox(
                  height: 5,
                ),
                Text("可用：${Util.formatSize(int.parse(volume['size']['total']) - int.parse(volume['size']['used']))}"),
                SizedBox(
                  height: 5,
                ),
                Text("容量：${Util.formatSize(int.parse(volume['size']['total']))}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSSDCacheItem(volume) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      child: Row(
        children: [
          NeuCard(
            curveType: CurveType.flat,
            margin: EdgeInsets.all(10),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(80),
              // color: Colors.red,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5),
            bevel: 8,
            child: CircularPercentIndicator(
              radius: 80,
              // progressColor: Colors.lightBlueAccent,
              animation: true,
              linearGradient: LinearGradient(
                colors: int.parse(volume['size']['used']) / int.parse(volume['size']['total']) <= 0.9
                    ? [
                        Colors.blue,
                        Colors.blueAccent,
                      ]
                    : [
                        Colors.red,
                        Colors.orangeAccent,
                      ],
              ),
              animateFromLastPercent: true,
              circularStrokeCap: CircularStrokeCap.round,
              lineWidth: 12,
              backgroundColor: Colors.black12,
              percent: int.parse(volume['size']['used']) / int.parse(volume['size']['total']),
              center: Text(
                "${(int.parse(volume['size']['used']) / int.parse(volume['size']['total']) * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: int.parse(volume['size']['used']) / int.parse(volume['size']['total']) <= 0.9 ? Colors.blue : Colors.red, fontSize: 22),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "${volume['id'].toString().replaceFirst("ssd_", "SSD 缓存 ")}",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Label(
                      volume['status'] == "normal" ? "正常" : volume['status'],
                      volume['status'] == "normal" ? Colors.green : Colors.red,
                      fill: true,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text("已用：${Util.formatSize(int.parse(volume['size']['used']))}"),
                SizedBox(
                  height: 5,
                ),
                Text("可用：${Util.formatSize(int.parse(volume['size']['total']) - int.parse(volume['size']['used']))}"),
                SizedBox(
                  height: 5,
                ),
                Text("容量：${Util.formatSize(int.parse(volume['size']['total']))}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInterfaceItem(interface) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Text("${interface['id']}："),
          Text("${interface['ipaddr']}"),
        ],
      ),
    );
  }

  Widget _buildApplicationItem(application) {
    Widget icon = Container();
    String title = "";
    switch (application) {
      case "SYNO.SDS.AdminCenter.Application":
        icon = Image.asset(
          "assets/applications/control_panel.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.EzInternet.Instance":
        icon = Image.asset(
          "assets/applications/ez_internet.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.HelpBrowser.Application":
        icon = Image.asset(
          "assets/applications/help.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.PkgManApp.Instance":
        icon = Image.asset(
          "assets/applications/package_center.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.ResourceMonitor.Instance":
        icon = Image.asset(
          "assets/applications/resource_monitor.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.StorageManager.Instance":
        icon = Image.asset(
          "assets/applications/storage_manager.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.LogCenter.Instance":
        icon = Image.asset(
          "assets/applications/log_center.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.SecurityScan.Instance":
        icon = Image.asset(
          "assets/applications/security_scan.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.SupportForm.Application":
        icon = Image.asset(
          "assets/applications/support_center.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.iSCSI.Application":
        icon = Image.asset(
          "assets/applications/iSCSI_manager.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.SDS.App.FileStation3.Instance":
        icon = Image.asset(
          "assets/applications/file_browser.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      case "SYNO.Finder.Application":
        icon = Image.asset(
          "assets/applications/search.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
      default:
        icon = Image.asset(
          "assets/applications/search.png",
          height: 45,
          width: 45,
          fit: BoxFit.contain,
        );
        break;
    }

    return NeuCard(
      width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                icon,
                SizedBox(
                  height: 5,
                ),
                Text("套件中心"),
              ],
            ),
          ),
          if (appNotify != null && appNotify[application] != null)
            Positioned(
              right: 30,
              child: Badge(
                appNotify[application]['unread'],
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "控制台",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
          child: NeuButton(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            bevel: 5,
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
            child: Image.asset(
              "assets/icons/application.png",
              width: 20,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: NeuButton(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              bevel: 5,
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                  return Notify(notifies, strings);
                }));
              },
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.asset(
                    "assets/icons/message.png",
                    width: 20,
                    height: 20,
                  ),
                  if (notifies.length > 0)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 5,
                      height: 5,
                    )
                ],
              ),
            ),
          )
        ],
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
          : success
              ? widgets != null && widgets.length > 0
                  ? ListView(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      children: widgets.map((widget) {
                        return _buildWidgetItem(widget);
                        // return Text(widget);
                      }).toList(),
                    )
                  : Center(
                      child: Text(
                        "无可用小组件",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$msg"),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: NeuButton(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          bevel: 5,
                          onPressed: () {
                            getData();
                          },
                          child: Text(
                            ' 刷新 ',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      drawer: applications != null && applications.length > 0
          ? Container(
              width: MediaQuery.of(context).size.width * 0.8,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        if (applications.contains("SYNO.SDS.AdminCenter.Application"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            height: 110,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/applications/control_panel.png",
                                        height: 45,
                                        width: 45,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("控制面板"),
                                    ],
                                  ),
                                ),
                                if (appNotify != null && appNotify['SYNO.SDS.AdminCenter.Application'] != null)
                                  Positioned(
                                    right: 30,
                                    child: Badge(
                                      appNotify['SYNO.SDS.AdminCenter.Application']['unread'],
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.EzInternet.Instance"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            height: 110,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/applications/ez_internet.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("EZ-Internet"),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.HelpBrowser.Application"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/applications/help.png",
                                        height: 45,
                                        width: 45,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("DSM 说明"),
                                    ],
                                  ),
                                ),
                                if (appNotify != null && appNotify['SYNO.SDS.HelpBrowser.Application'] != null)
                                  Positioned(
                                    right: 30,
                                    child: Badge(
                                      appNotify['SYNO.SDS.PkgManApp.Instance']['unread'],
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.PkgManApp.Instance"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/applications/package_center.png",
                                        height: 45,
                                        width: 45,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("套件中心"),
                                    ],
                                  ),
                                ),
                                if (appNotify != null && appNotify['SYNO.SDS.PkgManApp.Instance'] != null)
                                  Positioned(
                                    right: 30,
                                    child: Badge(
                                      appNotify['SYNO.SDS.PkgManApp.Instance']['unread'],
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.ResourceMonitor.Instance"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/applications/resource_monitor.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("资源监控"),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.StorageManager.Instance"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/applications/storage_manager.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("存储空间管理员"),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.LogCenter.Instance"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/applications/log_center.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("日志中心"),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.SecurityScan.Instance"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/applications/security_scan.png",
                                        height: 45,
                                        width: 45,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("安全顾问"),
                                    ],
                                  ),
                                ),
                                if (appNotify != null && appNotify['SYNO.SDS.SecurityScan.Instance'] != null)
                                  Positioned(
                                    right: 30,
                                    child: Badge(
                                      appNotify['SYNO.SDS.SecurityScan.Instance']['unread'],
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.SupportForm.Application"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/applications/support_center.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("技术支持中心"),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.iSCSI.Application"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/applications/iSCSI_manager.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("iSCSI Manager"),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.SDS.App.FileStation3.Instance"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/applications/file_browser.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("File Station"),
                              ],
                            ),
                          ),
                        if (applications.contains("SYNO.Finder.Application"))
                          NeuCard(
                            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                            curveType: CurveType.flat,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/applications/search.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("Universal Search"),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
