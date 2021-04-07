import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:dsm_helper/pages/common/browser.dart';
import 'package:dsm_helper/pages/control_panel/control_panel.dart';
import 'package:dsm_helper/pages/control_panel/external_device/external_device.dart';
import 'package:dsm_helper/pages/control_panel/task_scheduler/task_scheduler.dart';
import 'package:dsm_helper/pages/dashborad/media_converter.dart';
import 'package:dsm_helper/pages/docker/detail.dart';
import 'package:dsm_helper/pages/moments/moments.dart';
import 'package:dsm_helper/pages/notify/notify.dart';
import 'package:dsm_helper/pages/dashborad/widget_setting.dart';
import 'package:dsm_helper/pages/docker/docker.dart';
import 'package:dsm_helper/pages/download_station/download_station.dart';
import 'package:dsm_helper/pages/log_center/log_center.dart';
import 'package:dsm_helper/pages/packages/packages.dart';
import 'package:dsm_helper/pages/provider/shortcut.dart';
import 'package:dsm_helper/pages/provider/wallpaper.dart';
import 'package:dsm_helper/pages/resource_monitor/performance.dart';
import 'package:dsm_helper/pages/resource_monitor/resource_monitor.dart';
import 'package:dsm_helper/pages/security_scan/security_scan.dart';
import 'package:dsm_helper/pages/storage_manager/storage_manager.dart';
import 'package:dsm_helper/pages/control_panel/info/info.dart';
import 'package:dsm_helper/pages/universal_search/universal_search.dart';
import 'package:dsm_helper/pages/virtual_machine/virtual_machine.dart';
import 'package:dsm_helper/util/badge.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:provider/provider.dart';

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
  List fileLogs = [];
  List shortcutItems = [];
  List esatas = [];
  Map appNotify;
  Map system;
  Map restoreSizePos;
  Map converter;
  bool loading = true;
  bool success = true;
  String hostname = "获取中";
  int maxNetworkSpeed = 0;
  Map volWarnings;
  String msg = "";
  bool showMainMenu = false;
  @override
  void initState() {
    Util.getStorage("account").then((value) {
      setState(() {
        showMainMenu = value != "challengerv";
      });
    });
    showFirstLaunchDialog();
    getNotifyStrings();
    getInfo().then((_) {
      getData();
    });
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

  showFirstLaunchDialog() async {
    bool firstLaunch = await Util.getStorage("first_launch") == null;
    if (firstLaunch) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeuCard(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    curveType: CurveType.emboss,
                    bevel: 5,
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            "群晖助手公众号",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            bevel: 20,
                            curveType: CurveType.flat,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            child: Text("关注公众号，获取最新群晖助手更新内容、操作说明，浏览广告内容，还可以获取现金红包奖励！"),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: NeuButton(
                                  onPressed: () async {
                                    ClipboardData data = new ClipboardData(text: "群晖助手");
                                    Clipboard.setData(data);
                                    Util.toast("已复制到剪贴板");
                                    Navigator.of(context).pop();
                                    Util.setStorage("first_launch", "0");
                                  },
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  bevel: 20,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "复制",
                                    style: TextStyle(fontSize: 18),
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
                                    Util.setStorage("first_launch", "0");
                                  },
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  bevel: 20,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "不再提示",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    }
  }

  getNotifyStrings() async {
    var res = await Api.notifyStrings();
    if (res['success']) {
      setState(() {
        Util.notifyStrings = res['data'];
      });
    }
  }

  getExternalDevice() async {
    var res = await Api.externalDevice();
    if (res['success']) {
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.Core.ExternalDevice.Storage.eSATA":
              setState(() {
                esatas = item['data']['devices'];
              });
          }
        }
      });
    }
  }

  getMediaConverter() async {
    var res = await Api.mediaConverter("status");
    if (res['success']) {
      setState(() {
        converter = res['data'];
        if (converter != null && (converter['photo_remain'] + converter['thumb_remain'] + converter['video_remain'] > 0)) {
          Future.delayed(Duration(seconds: 5)).then((value) => getMediaConverter());
        }
      });
    }
  }

  Future<void> getInfo() async {
    var init = await Api.initData();
    if (init['success']) {
      setState(() {
        if (init['data']['UserSettings'] != null) {
          if (init['data']['UserSettings']['SYNO.SDS._Widget.Instance'] != null) {
            widgets = init['data']['UserSettings']['SYNO.SDS._Widget.Instance']['modulelist'] ?? [];
            restoreSizePos = init['data']['UserSettings']['SYNO.SDS._Widget.Instance']['restoreSizePos'];
          }
          applications = init['data']['UserSettings']['Desktop']['appview_order'] ?? init['data']['UserSettings']['Desktop']['valid_appview_order'];
          if (init['data']['UserSettings']['Desktop']['ShortcutItems'] != null) {
            setState(() {
              shortcutItems = init['data']['UserSettings']['Desktop']['ShortcutItems'];
            });
          }
        }
        if (init['data']['Session'] != null) {
          hostname = init['data']['Session']['hostname'];
          Util.hostname = hostname;
        }
        if (init['data']['Strings'] != null) {
          Util.strings = init['data']['Strings'] ?? {};
        }
      });
    }
  }

  double get chartInterval {
    if (maxNetworkSpeed < 1024) {
      return 102.4;
    } else if (maxNetworkSpeed < pow(1024, 2)) {
      return 1024.0 * 200;
    } else if (maxNetworkSpeed < pow(1024, 2) * 5) {
      return 1.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 10) {
      return 2.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 20) {
      return 4.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 40) {
      return 8.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 50) {
      return 10.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 100) {
      return 20.0 * pow(1024, 2);
    } else {
      return 50.0 * pow(1024, 2);
    }
  }

  String chartTitle(double v) {
    if (maxNetworkSpeed < 1024) {
      v = v / 1024;
      return (v.floor() * 100).toString();
    } else if (maxNetworkSpeed < pow(1024, 2)) {
      String s = (v / 1024).floor().toString() + "K";
      if (s == "1000K") {
        return "1M";
      }
      return s;
    } else {
      v = v / pow(1024, 2);
      return (v.floor()).toString() + "M";
    }
  }

  getData() async {
    if (!mounted) {
      timer?.cancel();
      return;
    }
    if (timer == null) {
      timer = Timer.periodic(Duration(seconds: 10), (timer) {
        getData();
      });
    }
    getExternalDevice();
    getMediaConverter();
    var res = await Api.systemInfo(widgets);

    if (res['success']) {
      if (!mounted) {
        return;
      }
      setState(() {
        loading = false;
        success = true;
      });
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.Core.System.Utilization":
              setState(() {
                utilization = item['data'];
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
                Util.systemVersion(system['firmware_ver']);
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
            case "SYNO.Core.SyslogClient.Log":
              setState(() {
                fileLogs = item['data']['items'];
              });
              break;
          }
        }

        // else if(item['api'] == ""){
        //
        // }
      });
    } else {
      setState(() {
        if (loading) {
          success = res['success'];
          loading = false;
        }

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
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          bevel: 20,
          curveType: CurveType.flat,
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Consumer<WallpaperProvider>(
                builder: (context, wallpaperProvider, _) {
                  return wallpaperProvider.showWallpaper
                      ? Container(
                          height: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: ExtendedNetworkImageProvider(Util.baseUrl +
                                  "/webapi/entry.cgi?api=SYNO.Core.PersonalSettings&method=wallpaper&version=1&path=%22%22&retina=true&_sid=${Util.sid}"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container();
                },
              ),
              if (Theme.of(context).scaffoldBackgroundColor == Colors.black)
                Container(
                  height: 170,
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headline6.color,
                      shadows: [
                        BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 5),
                      ],
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
                        if (system != null && system['sys_temp'] != null)
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Row(
                              children: [
                                Text("散热状态："),
                                Text(
                                  "${system['sys_temp']}℃ ${system['temperature_warning'] == null ? (system['sys_temp'] > 80 ? "警告" : "正常") : (system['temperature_warning'] ? "警告" : "正常")}",
                                  style: TextStyle(
                                      color: system['temperature_warning'] == null
                                          ? (system['sys_temp'] > 80 ? Colors.red : Colors.green)
                                          : (system['temperature_warning'] ? Colors.red : Colors.green)),
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
    } else if (widget == "SYNO.SDS.TaskScheduler.TaskSchedulerWidget") {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return TaskScheduler();
          }));
        },
        child: NeuCard(
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
        ),
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.RecentLogWidget") {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) {
                return LogCenter();
              },
              settings: RouteSettings(name: "log_center")));
        },
        child: NeuCard(
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
                child: latestLog.length > 0
                    ? CupertinoScrollbar(
                        child: ListView.builder(
                          itemBuilder: (context, i) {
                            return _buildLogItem(latestLog[i]);
                          },
                          itemCount: latestLog.length,
                        ),
                      )
                    : Center(
                        child: Text("暂无日志"),
                      ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      );
    } else if (widget == "SYNO.SDS.ResourceMonitor.Widget") {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return ResourceMonitor();
          }));
        },
        child: NeuCard(
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
              if (utilization != null) ...[
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) {
                          return Performance(
                            tabIndex: 1,
                          );
                        },
                        settings: RouteSettings(name: "performance")));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
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
                              currentValue: utilization['cpu']['user_load'] + utilization['cpu']['system_load'],
                              displayText: '%',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) {
                          return Performance(
                            tabIndex: 2,
                          );
                        },
                        settings: RouteSettings(name: "performance")));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SizedBox(width: 60, child: Text("RAM：")),
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
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) {
                          return Performance(
                            tabIndex: 3,
                          );
                        },
                        settings: RouteSettings(name: "performance")));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SizedBox(width: 60, child: Text("网络：")),
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
                ),
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) {
                          return Performance(
                            tabIndex: 3,
                          );
                        },
                        settings: RouteSettings(name: "performance")));
                  },
                  child: AspectRatio(
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
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Padding(
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
                              minY: 0,
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
                  ),
                ),
              ] else
                SizedBox(
                  height: 300,
                  child: Center(child: Text("数据加载失败")),
                ),
            ],
          ),
        ),
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.StorageUsageWidget") {
      return Column(
        children: [
          GestureDetector(
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
          ),
          if (ssdCaches != null && ssdCaches.length > 0)
            NeuCard(
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
            )
        ],
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.FileChangeLogWidget") {
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
                    "assets/icons/file_change.png",
                    width: 26,
                    height: 26,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "文件更改日志",
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
              child: fileLogs.length > 0
                  ? CupertinoScrollbar(
                      child: ListView.builder(
                        itemBuilder: (context, i) {
                          return _buildFileLogItem(fileLogs[i]);
                        },
                        itemCount: fileLogs.length,
                      ),
                    )
                  : Center(
                      child: Text("暂无日志"),
                    ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildUserItem(user) {
    user['running'] = user['running'] ?? false;
    DateTime loginTime = DateTime.parse(user['time'].toString().replaceAll("/", "-"));
    DateTime currentTime = DateTime.now();
    Map timeLong = Util.timeLong(currentTime.difference(loginTime).inSeconds);
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      curveType: CurveType.flat,
      child: Padding(
        padding: EdgeInsets.all(10),
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
            NeuButton(
              onPressed: () async {
                if (user['running']) {
                  return;
                }
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: Colors.transparent,
                      child: NeuCard(
                        width: double.infinity,
                        bevel: 5,
                        curveType: CurveType.emboss,
                        decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                        child: Padding(
                          padding: EdgeInsets.all(20),
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
                                        setState(() {
                                          user['running'] = true;
                                        });
                                        var res = await Api.kickConnection({"who": user['who'], "from": user['from']});
                                        setState(() {
                                          user['running'] = false;
                                        });

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
                      ),
                    );
                  },
                );
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
                child: user['running']
                    ? CupertinoActivityIndicator()
                    : Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(task) {
    task['running'] = task['running'] ?? false;
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      curveType: CurveType.flat,
      child: Padding(
        padding: EdgeInsets.all(10),
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
            SizedBox(
              width: 5,
            ),
            NeuButton(
              onPressed: () async {
                if (task['running']) {
                  return;
                }
                setState(() {
                  task['running'] = true;
                });
                var res = await Api.taskRun([task['id']]);
                setState(() {
                  task['running'] = false;
                });
                if (res['success']) {
                  Util.toast("任务计划执行成功");
                } else {
                  Util.toast("任务计划执行失败，code：${res['error']['code']}");
                }
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
                child: task['running']
                    ? CupertinoActivityIndicator()
                    : Icon(
                        CupertinoIcons.play_arrow_solid,
                        color: Color(0xffff9813),
                        size: 16,
                      ),
              ),
            ),
          ],
        ),
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

  Widget _buildFileLogItem(log) {
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
          Icon(log['cmd'] == "delete"
              ? Icons.delete
              : log['cmd'] == "copy"
                  ? Icons.copy
                  : log['cmd'] == "edit"
                      ? Icons.edit
                      : log['cmd'] == "move"
                          ? Icons.drive_file_move_outline
                          : log['cmd'] == "download"
                              ? Icons.download_outlined
                              : log['cmd'] == "upload"
                                  ? Icons.upload_outlined
                                  : log['cmd'] == "rename"
                                      ? Icons.drive_file_rename_outline
                                      : Icons.code),
          Expanded(
            child: Text(
              "${log['descr']}",
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
                    volume['status'] == "normal"
                        ? Label(
                            "正常",
                            Colors.green,
                            fill: true,
                          )
                        : volume['status'] == "background"
                            ? Label(
                                "正在检查硬盘",
                                Colors.lightBlueAccent,
                                fill: true,
                              )
                            : volume['status'] == "attention"
                                ? Label(
                                    "注意",
                                    Colors.orangeAccent,
                                    fill: true,
                                  )
                                : Label(
                                    volume['status'],
                                    Colors.red,
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

  List<Widget> _buildApplicationList() {
    List<Widget> apps = [];
    if (applications.contains("SYNO.SDS.AdminCenter.Application")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return ControlPanel(system, volumes, disks, appNotify['SYNO.SDS.AdminCenter.Application']['fn']);
                },
                settings: RouteSettings(name: "control_panel")));
          },
          child: NeuCard(
            width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
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
                        "assets/applications/${Util.version}/control_panel.png",
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
        ),
      );
    }

    // if (applications.contains("SYNO.SDS.EzInternet.Instance")) {
    //   apps.add(
    //     NeuCard(
    //       width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //       height: 110,
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       curveType: CurveType.flat,
    //       decoration: NeumorphicDecoration(
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         borderRadius: BorderRadius.circular(20),
    //       ),
    //       bevel: 20,
    //       child: Column(
    //         children: [
    //           Image.asset(
    //             "assets/applications/ez_internet.png",
    //             height: 45,
    //             width: 45,
    //             fit: BoxFit.contain,
    //           ),
    //           SizedBox(
    //             height: 5,
    //           ),
    //           Text("EZ-Internet"),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    if (applications.contains("SYNO.SDS.PkgManApp.Instance")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return Packages(system['firmware_ver']);
                },
                settings: RouteSettings(name: "packages")));
          },
          child: NeuCard(
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
                        "assets/applications/${Util.version}/package_center.png",
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
        ),
      );
    }
    if (applications.contains("SYNO.SDS.ResourceMonitor.Instance")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return ResourceMonitor();
                },
                settings: RouteSettings(name: "resource_monitor")));
          },
          child: NeuCard(
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
                  "assets/applications/${Util.version}/resource_monitor.png",
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
        ),
      );
    }
    if (applications.contains("SYNO.SDS.StorageManager.Instance")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return StorageManager();
                },
                settings: RouteSettings(name: "storage_manager")));
          },
          child: NeuCard(
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
                  "assets/applications/${Util.version}/storage_manager.png",
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
        ),
      );
    }
    if (applications.contains("SYNO.SDS.LogCenter.Instance")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return LogCenter();
                },
                settings: RouteSettings(name: "log_center")));
          },
          child: NeuCard(
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
                  "assets/applications/${Util.version}/log_center.png",
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
        ),
      );
    }
    if (applications.contains("SYNO.SDS.SecurityScan.Instance")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return SecurityScan();
                },
                settings: RouteSettings(name: "security_scan")));
          },
          child: NeuCard(
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
                        "assets/applications/${Util.version}/security_scan.png",
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
        ),
      );
    }
    // if (applications.contains("SYNO.SDS.SupportForm.Application")) {
    //   apps.add(
    //     NeuCard(
    //       width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //       curveType: CurveType.flat,
    //       decoration: NeumorphicDecoration(
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         borderRadius: BorderRadius.circular(20),
    //       ),
    //       bevel: 20,
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       child: Column(
    //         children: [
    //           Image.asset(
    //             "assets/applications/support_center.png",
    //             height: 45,
    //             width: 45,
    //             fit: BoxFit.contain,
    //           ),
    //           SizedBox(
    //             height: 5,
    //           ),
    //           Text("技术支持中心"),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    // if (applications.contains("SYNO.SDS.iSCSI.Application")) {
    //   apps.add(
    //     GestureDetector(
    //       onTap: () {
    //         Navigator.of(context).pop();
    //         Navigator.of(context).push(CupertinoPageRoute(
    //             builder: (context) {
    //               return ISCSIManger();
    //             },
    //             settings: RouteSettings(name: "iSCSI_manager")));
    //       },
    //       child: NeuCard(
    //         width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //         curveType: CurveType.flat,
    //         decoration: NeumorphicDecoration(
    //           color: Theme.of(context).scaffoldBackgroundColor,
    //           borderRadius: BorderRadius.circular(20),
    //         ),
    //         bevel: 20,
    //         padding: EdgeInsets.symmetric(vertical: 20),
    //         child: Column(
    //           children: [
    //             Image.asset(
    //               "assets/applications/iSCSI_manager.png",
    //               height: 45,
    //               width: 45,
    //               fit: BoxFit.contain,
    //             ),
    //             SizedBox(
    //               height: 5,
    //             ),
    //             Text("iSCSI Manager"),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // if (applications.contains("SYNO.SDS.App.FileStation3.Instance")) {
    //   apps.add(
    //     NeuCard(
    //       width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //       curveType: CurveType.flat,
    //       decoration: NeumorphicDecoration(
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         borderRadius: BorderRadius.circular(20),
    //       ),
    //       bevel: 20,
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       child: Column(
    //         children: [
    //           Image.asset(
    //             "assets/applications/file_browser.png",
    //             height: 45,
    //             width: 45,
    //             fit: BoxFit.contain,
    //           ),
    //           SizedBox(
    //             height: 5,
    //           ),
    //           Text("File Station"),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    if (applications.contains("SYNO.Finder.Application")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return UniversalSearch();
                },
                settings: RouteSettings(name: "universal_search")));
          },
          child: NeuCard(
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
                  "assets/applications/${Util.version}/universal_search.png",
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
        ),
      );
    }
    if (applications.contains("SYNO.SDS.Virtualization.Application")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) {
                return VirtualMachine();
              },
              settings: RouteSettings(name: "virtual_machine_manager"),
            ));
          },
          child: NeuCard(
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
                  "assets/applications/${Util.version}/virtual_machine.png",
                  height: 45,
                  width: 45,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Virtual Machine Manager",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (applications.contains("SYNO.SDS.Docker.Application")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) {
                return Docker();
              },
              settings: RouteSettings(name: "docker"),
            ));
          },
          child: NeuCard(
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
                  "assets/applications/docker.png",
                  height: 45,
                  width: 45,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Docker",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }
    // print(applications);
    if (applications.contains("SYNO.SDS.DownloadStation.Application")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) {
                return DownloadStation();
              },
              settings: RouteSettings(name: "download_station"),
            ));
          },
          child: NeuCard(
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
                  "assets/applications/download_station.png",
                  height: 45,
                  width: 45,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Download Station",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (applications.contains("SYNO.Photo.AppInstance")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) {
                return Moments();
              },
              settings: RouteSettings(name: "moments"),
            ));
          },
          child: NeuCard(
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
                  "assets/applications/6/moments.png",
                  height: 45,
                  width: 45,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Moments",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (applications.contains("SYNO.Foto.AppInstance")) {
      apps.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) {
                return Moments();
              },
              settings: RouteSettings(name: "moments"),
            ));
          },
          child: NeuCard(
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
                  "assets/applications/7/synology_photos.png",
                  height: 45,
                  width: 45,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Synology Photos",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }
    //SYNO.SDS.PhotoStation  6.0 photo station
    //SYNO.Foto.AppInstance  7.0 photo
    // print(applications);
    return apps;
  }

  Widget _buildESataItem(esata) {
    return NeuCard(
      margin: EdgeInsets.only(bottom: 20),
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
                Text(
                  "${esata['dev_title']}",
                ),
                SizedBox(
                  width: 10,
                ),
                esata['status'] == "normal"
                    ? Label(
                        "正常",
                        Colors.green,
                        fill: true,
                      )
                    : Label(
                        esata['status'],
                        Colors.red,
                        fill: true,
                      ),
                SizedBox(
                  width: 10,
                ),
                Spacer(),
                NeuButton(
                  onPressed: () async {
                    var res = await Api.ejectEsata(esata['dev_id']);
                    if (res['success']) {
                      Util.toast("设备已退出");
                      getData();
                    } else {
                      Util.toast("设备退出失败，代码${res['error']['code']}");
                    }
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
                      CupertinoIcons.eject,
                      color: Color(0xffff9813),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutItem(shortcut) {
    String icon = "";
    String name = "";
    CupertinoPageRoute route;
    int unread = 0;
    switch (shortcut['className']) {
      case "SYNO.SDS.PkgManApp.Instance":
        icon = "assets/applications/${Util.version}/package_center.png";
        name = "套件中心";
        route = CupertinoPageRoute(
            builder: (context) {
              return Packages(system['firmware_ver']);
            },
            settings: RouteSettings(name: "packages"));
        if (appNotify != null && appNotify['SYNO.SDS.PkgManApp.Instance'] != null) {
          unread = appNotify['SYNO.SDS.PkgManApp.Instance']['unread'];
        }
        break;
      case "SYNO.SDS.AdminCenter.Application":
        icon = "assets/applications/${Util.version}/control_panel.png";
        name = "控制面板";
        route = CupertinoPageRoute(
            builder: (context) {
              return ControlPanel(
                  system, volumes, disks, appNotify['SYNO.SDS.AdminCenter.Application'] == null ? null : appNotify['SYNO.SDS.AdminCenter.Application']['fn']);
            },
            settings: RouteSettings(name: "control_panel"));
        if (appNotify != null && appNotify['SYNO.SDS.AdminCenter.Application'] != null) {
          unread = appNotify['SYNO.SDS.AdminCenter.Application']['unread'];
        }
        break;
      case "SYNO.SDS.StorageManager.Instance":
        icon = "assets/applications/${Util.version}/storage_manager.png";
        name = "存储空间管理员";
        route = CupertinoPageRoute(
            builder: (context) {
              return StorageManager();
            },
            settings: RouteSettings(name: "storage_manager"));
        break;
      case "SYNO.SDS.Docker.Application":
        icon = "assets/applications/docker.png";
        name = "Docker";
        route = CupertinoPageRoute(
          builder: (context) {
            return Docker();
          },
          settings: RouteSettings(name: "docker"),
        );
        break;
      case "SYNO.SDS.Docker.ContainerDetail.Instance":
        icon = "assets/applications/docker.png";
        name = "${shortcut['param']['data']['name']}";
        if (shortcut['type'] == 'url') {
          route = CupertinoPageRoute(
            builder: (context) {
              return Browser(
                url: shortcut['url'],
                title: name,
              );
            },
            settings: RouteSettings(name: "browser"),
          );
        } else {
          route = CupertinoPageRoute(
            builder: (context) {
              return ContainerDetail(name);
            },
            settings: RouteSettings(name: "docker_container_detail"),
          );
        }

        break;
      case "SYNO.SDS.LogCenter.Instance":
        icon = "assets/applications/${Util.version}/log_center.png";
        name = "日志中心";
        route = CupertinoPageRoute(
            builder: (context) {
              return LogCenter();
            },
            settings: RouteSettings(name: "log_center"));
        break;
      case "SYNO.SDS.ResourceMonitor.Instance":
        icon = "assets/applications/${Util.version}/resource_monitor.png";
        name = "资源监控";
        route = CupertinoPageRoute(
            builder: (context) {
              return ResourceMonitor();
            },
            settings: RouteSettings(name: "resource_monitor"));

        break;
      // case "SYNO.SDS.SecurityScan.Instance":
      //   icon = "assets/applications/security_scan.png";
      //   break;
      case "SYNO.SDS.Virtualization.Application":
        icon = "assets/applications/${Util.version}/virtual_machine.png";
        name = "Virtual Machine Manager";
        route = CupertinoPageRoute(
          builder: (context) {
            return VirtualMachine();
          },
          settings: RouteSettings(name: "virtual_machine_manager"),
        );
        break;
      case "SYNO.SDS.DownloadStation.Application":
        icon = "assets/applications/download_station.png";
        name = "Download Station";
        route = CupertinoPageRoute(
          builder: (context) {
            return DownloadStation();
          },
          settings: RouteSettings(name: "download_station"),
        );
        break;
    }
    if (icon != "") {
      return Padding(
        padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(route);
          },
          child: NeuCard(
            bevel: 20,
            width: 100,
            curveType: CurveType.flat,
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Image.asset(
                          icon,
                          width: 50,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$name",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Badge(
                    unread,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "控制台",
        ),
        leadingWidth: 180,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMainMenu)
              Padding(
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
            if (esatas.length > 0)
              Padding(
                padding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
                child: NeuButton(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
                  bevel: 5,
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return Material(
                          color: Colors.transparent,
                          child: NeuCard(
                            width: double.infinity,
                            bevel: 5,
                            curveType: CurveType.emboss,
                            decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "外接设备",
                                    style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  ...esatas.map(_buildESataItem).toList(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: NeuButton(
                                          onPressed: () async {
                                            Navigator.of(context).push(CupertinoPageRoute(
                                                builder: (context) {
                                                  return ExternalDevice();
                                                },
                                                settings: RouteSettings(name: "external_device")));
                                          },
                                          decoration: NeumorphicDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          bevel: 5,
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          child: Text(
                                            "查看详情",
                                            style: TextStyle(fontSize: 18),
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
                          ),
                        );
                      },
                    );
                  },
                  child: Image.asset(
                    "assets/icons/external_devices.png",
                    width: 20,
                  ),
                ),
              ),
            if (converter != null && (converter['photo_remain'] + converter['thumb_remain'] + converter['video_remain'] > 0))
              Padding(
                padding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
                child: NeuButton(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
                  bevel: 5,
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return MediaConverter(converter);
                        });
                  },
                  child: Image.asset(
                    "assets/icons/converter.gif",
                    width: 20,
                  ),
                ),
              ),
          ],
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
                  return WidgetSetting(widgets, restoreSizePos);
                })).then((res) {
                  if (res != null) {
                    setState(() {
                      widgets = res;
                      getData();
                    });
                  }
                });
              },
              child: Image.asset(
                "assets/icons/edit.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
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
                Navigator.of(context)
                    .push(CupertinoPageRoute(
                        builder: (context) {
                          return Notify(notifies);
                        },
                        settings: RouteSettings(name: "notify")))
                    .then((res) {
                  if (res != null && res) {
                    setState(() {
                      notifies = [];
                    });
                  }
                });
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
          ),
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
                      children: [
                        Consumer<ShortcutProvider>(
                          builder: (context, shortcutProvider, _) {
                            return shortcutProvider.showShortcut
                                ? NeuCard(
                                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    bevel: 20,
                                    curveType: CurveType.flat,
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      height: 140,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, i) {
                                          return _buildShortcutItem(shortcutItems[i]);
                                        },
                                        itemCount: shortcutItems.length,
                                      ),
                                    ),
                                  )
                                : Container();
                          },
                        ),
                        ...widgets.map((widget) {
                          return _buildWidgetItem(widget);
                          // return Text(widget);
                        }).toList(),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "未添加小组件",
                          ),
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
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                  return WidgetSetting(widgets, restoreSizePos);
                                })).then((res) {
                                  if (res != null) {
                                    setState(() {
                                      widgets = res;
                                      getData();
                                    });
                                  }
                                });
                              },
                              child: Text(
                                ' 添加 ',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
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
                      children: _buildApplicationList(),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
