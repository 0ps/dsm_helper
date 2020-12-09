import 'dart:async';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Timer timer;
  Map utilization;
  List volumes = [];
  List connectedUsers = [];
  List interfaces = [];
  List networks = [];
  List ssdCaches = [];
  Map system;
  bool loading = true;
  bool success = true;
  String hostname = "获取中";
  Map volWarnings;
  String msg = "";
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  @override
  void initState() {
    getData();
    getInfo();
    super.initState();
  }

  getInfo() async {
    var res = await Api.info();
    if (res['success'] != null && res['success'] == false) {
      // print(res);
    } else {
      if (mounted) {
        setState(() {
          interfaces = res['interfaces'];
          volWarnings = res['vol_warnings'];
        });
      } else {
        if (timer != null) {
          timer.cancel();
          timer = null;
        }
      }
    }
    var init = await Api.initData();
    if (init['success']) {
      setState(() {
        hostname = init['data']['Session']['hostname'];
      });
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
      loading = false;
      success = res['success'];
    });
    if (res['success']) {
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          if (item['api'] == "SYNO.Core.System.Utilization") {
            setState(() {
              utilization = item['data'];
              // print(utilization);
              if (networks.length > 20) {
                networks.removeAt(0);
              }
              networks.add(item['data']['network']);
            });
          } else if (item['api'] == "SYNO.Core.System") {
            // print(item['data']);
            setState(() {
              // volumes = item['data']['vol_info'];
              system = item['data'];
              // print(system);
            });
          } else if (item['api'] == "SYNO.Core.CurrentConnection") {
            setState(() {
              connectedUsers = item['data']['items'];
            });
          } else if (item['api'] == "SYNO.Storage.CGI.Storage") {
            setState(() {
              ssdCaches = item['data']['ssdCaches'];
              volumes = item['data']['volumes'];
            });
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

  Widget _buildUserItem(user) {
    DateTime loginTime = DateTime.parse(user['time'].toString().replaceAll("/", "-"));
    DateTime currentTime = DateTime.now();
    Map timeLong = Util.timeLong(currentTime.difference(loginTime).inSeconds);
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
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
                      "${volume['deploy_path'].toString().replaceFirst("volume_", "存储空间 ")}",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "控制台",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
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
              ? ListView(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    NeuCard(
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
                          GestureDetector(
                            onTap: () {
                              getInfo();
                            },
                            child: Row(
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
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          if (system['model'] != null)
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
                          if (system['sys_temp'] != null && system['temperature_warning'] != null)
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Text("散热状态："),
                                  Text(
                                    "${system['sys_temp']}℃ ${system['temperature_warning'] == true ? "警告" : "正常"}",
                                    style: TextStyle(color: system['temperature_warning'] ? Colors.red : Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          if (system['up_time'] != null && system['up_time'] != "")
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Text("运行时间："),
                                  Text("${Util.parseOpTime(system['up_time'])}"),
                                ],
                              ),
                            ),
                          ...interfaces.map(_buildInterfaceItem).toList(),
                        ],
                      ),
                    ),
                    if (connectedUsers.length > 0)
                      NeuCard(
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
                      ),
                    if (utilization != null)
                      NeuCard(
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
                                          getTitles: (value) {
                                            value = value / 1000 / 1000;
                                            return (value.floor() * 1000).toString();
                                          },
                                          reservedSize: 28,
                                          interval: 1000 * 1000.0,
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
                      ),
                    if (volumes != null && volumes.length > 0)
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
                      ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
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
    );
  }
}
