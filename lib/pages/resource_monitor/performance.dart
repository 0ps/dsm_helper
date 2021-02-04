import 'dart:async';
import 'dart:math';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';

class Performance extends StatefulWidget {
  Performance({this.tabIndex = 0});
  final int tabIndex;
  @override
  _PerformanceState createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool loading = true;
  List cpus = [];
  List memories = [];
  List networks = [];
  List disks = [];
  List spaces = [];
  List luns = [];
  List colors = [
    Colors.red,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.green,
    Colors.amber,
    Colors.orange,
    Colors.teal,
    Colors.indigoAccent,
    Colors.cyanAccent,
    Colors.yellow,
    Colors.black,
    Colors.lightGreenAccent,
    Colors.pinkAccent
  ];
  Timer timer;
  int maxNetworkSpeed = 0;
  int maxDiskReadSpeed = 0;
  int maxDiskWriteSpeed = 0;
  int maxVolumeReadSpeed = 0;
  int maxVolumeWriteSpeed = 0;

  int networkCount = 0;
  @override
  void initState() {
    _tabController = TabController(initialIndex: widget.tabIndex, length: 6, vsync: this);
    getData();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getData();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  getData() async {
    var res = await Api.utilization();
    if (res['success']) {
      if (mounted)
        setState(() {
          loading = false;
          if (cpus.length > 30) {
            cpus.removeAt(0);
            disks.removeAt(0);
            luns.removeAt(0);
            memories.removeAt(0);
            networks.removeAt(0);
            spaces.removeAt(0);
          }
          cpus.add(res['data']['cpu']);
          disks.add(res['data']['disk']);
          if (res['data']['disk']['total']['read_byte'] > maxDiskReadSpeed) {
            maxDiskReadSpeed = res['data']['disk']['total']['read_byte'];
          }
          if (res['data']['disk']['total']['write_byte'] > maxDiskWriteSpeed) {
            maxDiskWriteSpeed = res['data']['disk']['total']['write_byte'];
          }

          luns.add(res['data']['lun']);
          memories.add(res['data']['memory']);
          networks.add(res['data']['network']);
          int tx = int.parse("${res['data']['network'][0]['tx']}");
          int rx = int.parse("${res['data']['network'][0]['rx']}");
          networkCount = res['data']['network'].length;
          num maxSpeed = max(tx, rx);
          if (maxSpeed > maxNetworkSpeed) {
            maxNetworkSpeed = maxSpeed;
          }
          spaces.add(res['data']['space']);
          if (res['data']['space']['total']['read_byte'] > maxVolumeReadSpeed) {
            maxVolumeReadSpeed = res['data']['space']['total']['read_byte'];
          }
          if (res['data']['space']['total']['write_byte'] > maxVolumeWriteSpeed) {
            maxVolumeWriteSpeed = res['data']['space']['total']['write_byte'];
          }
        });
    } else {
      print("加载失败$res");
    }
  }

  double chartInterval(maxVal) {
    if (maxVal < 1024) {
      return 102.4;
    } else if (maxVal < pow(1024, 2)) {
      return 1024.0 * 200;
    } else if (maxVal < pow(1024, 2) * 5) {
      return 1.0 * pow(1024, 2);
    } else if (maxVal < pow(1024, 2) * 10) {
      return 2.0 * pow(1024, 2);
    } else if (maxVal < pow(1024, 2) * 20) {
      return 4.0 * pow(1024, 2);
    } else if (maxVal < pow(1024, 2) * 40) {
      return 8.0 * pow(1024, 2);
    } else if (maxVal < pow(1024, 2) * 50) {
      return 10.0 * pow(1024, 2);
    } else if (maxVal < pow(1024, 2) * 100) {
      return 20.0 * pow(1024, 2);
    } else {
      return 50.0 * pow(1024, 2);
    }
  }

  String chartTitle(double v, int maxVal) {
    if (maxVal < 1024) {
      v = v / 1024;
      return (v.floor() * 100).toString();
    } else if (maxVal < pow(1024, 2)) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("性能"),
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
                        child: Text("概览"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("CPU"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("内存"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("网络"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("磁盘"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("存储空间"),
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
                          SizedBox(
                            height: 20,
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "CPU",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      LineTooltipItem("利用率：${items[0].y.floor()}%", TextStyle(color: Colors.cyan)),
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
                                                // getTitles: chartTitle,
                                                // getTitles: (value) {
                                                //   value = value / 1000 / 1000;
                                                //   return (value.floor() * 1000).toString();
                                                // },
                                                reservedSize: 28,
                                                interval: 10,
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: 100,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: cpus.map((cpu) {
                                                  return FlSpot(cpus.indexOf(cpu).toDouble(), (cpu['user_load'] + cpu['system_load']).toDouble());
                                                }).toList(),
                                                isCurved: true,
                                                colors: [
                                                  Colors.cyan,
                                                ],
                                                barWidth: 2,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  colors: [Colors.cyan.withOpacity(0.2)],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "利用率（%）",
                                      ),
                                      Spacer(),
                                      Text(
                                        "${cpus.last['user_load'] + cpus.last['system_load']} %",
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "内存",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      LineTooltipItem("利用率：${items[0].y.floor()}%", TextStyle(color: Colors.orangeAccent)),
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
                                                // getTitles: chartTitle,
                                                // getTitles: (value) {
                                                //   value = value / 1000 / 1000;
                                                //   return (value.floor() * 1000).toString();
                                                // },
                                                reservedSize: 28,
                                                interval: 10,
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: 100,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: memories.map((memory) {
                                                  return FlSpot(memories.indexOf(memory).toDouble(), memory['real_usage'].toDouble());
                                                }).toList(),
                                                isCurved: true,
                                                colors: [
                                                  Colors.orangeAccent,
                                                ],
                                                barWidth: 2,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  colors: [Colors.orangeAccent.withOpacity(0.2)],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "利用率（%）",
                                      ),
                                      Spacer(),
                                      Text(
                                        "${memories.last['real_usage']} %",
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "网络",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                getTitles: (v) {
                                                  return chartTitle(v, maxNetworkSpeed);
                                                },
                                                reservedSize: 28,
                                                interval: chartInterval(maxNetworkSpeed),
                                              ),
                                            ),
                                            minY: 0,
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
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.upload_sharp,
                                        color: Colors.blue,
                                      ),
                                      Text(
                                        Util.formatSize(networks.last[0]['tx']) + "/S",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.download_sharp,
                                        color: Colors.green,
                                      ),
                                      Text(
                                        Util.formatSize(networks.last[0]['rx']) + "/S",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "磁盘",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      LineTooltipItem("利用率：${items[0].y.floor()}%", TextStyle(color: Colors.pink)),
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
                                                // getTitles: chartTitle,
                                                // getTitles: (value) {
                                                //   value = value / 1000 / 1000;
                                                //   return (value.floor() * 1000).toString();
                                                // },
                                                reservedSize: 28,
                                                interval: 10,
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: 100,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: disks.map((disk) {
                                                  return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['utilization'].toDouble());
                                                }).toList(),
                                                isCurved: true,
                                                colors: [
                                                  Colors.pink,
                                                ],
                                                barWidth: 2,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  colors: [Colors.pink.withOpacity(0.2)],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "利用率（%）",
                                      ),
                                      Spacer(),
                                      Text(
                                        "${disks.last['total']['utilization']} %",
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "存储空间",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      LineTooltipItem("利用率：${items[0].y.floor()}%", TextStyle(color: Colors.purpleAccent)),
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
                                                // getTitles: chartTitle,
                                                // getTitles: (value) {
                                                //   value = value / 1000 / 1000;
                                                //   return (value.floor() * 1000).toString();
                                                // },
                                                reservedSize: 28,
                                                interval: 10,
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: 100,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: spaces.map((space) {
                                                  return FlSpot(spaces.indexOf(space).toDouble(), space['total']['utilization'].toDouble());
                                                }).toList(),
                                                isCurved: true,
                                                colors: [
                                                  Colors.purpleAccent,
                                                ],
                                                barWidth: 2,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  colors: [Colors.purpleAccent.withOpacity(0.2)],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "利用率（%）",
                                      ),
                                      Spacer(),
                                      Text(
                                        "${spaces.last['total']['utilization']} %",
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: NeuCard(
                                curveType: CurveType.flat,
                                bevel: 20,
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                LineTooltipItem("用户：${items[2].y}%", TextStyle(color: Color(0xffBAE050))),
                                                LineTooltipItem("系统：${items[1].y - items[2].y}%", TextStyle(color: Color(0xff73B0EE))),
                                                LineTooltipItem("I/O：${items[0].y - items[1].y}%", TextStyle(color: Color(0xff5584C8))),
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
                                          // getTitles: chartTitle,
                                          // getTitles: (value) {
                                          //   value = value / 1000 / 1000;
                                          //   return (value.floor() * 1000).toString();
                                          // },
                                          reservedSize: 28,
                                          interval: 10,
                                        ),
                                      ),
                                      minY: 0,
                                      maxY: 100,
                                      // maxY: 20,
                                      borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: cpus.map((cpu) {
                                            return FlSpot(cpus.indexOf(cpu).toDouble(), (cpu['user_load'] + cpu['system_load'] + cpu['other_load']).toDouble());
                                          }).toList(),
                                          isCurved: true,
                                          colors: [Color(0xff5584C8)],
                                          barWidth: 2,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: false,
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            colors: [Color(0xff5584C8)],
                                          ),
                                        ),
                                        LineChartBarData(
                                          spots: cpus.map((cpu) {
                                            return FlSpot(cpus.indexOf(cpu).toDouble(), (cpu['user_load'] + cpu['system_load']).toDouble());
                                          }).toList(),
                                          isCurved: true,
                                          colors: [Color(0xff73B0EE)],
                                          barWidth: 2,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: false,
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            colors: [Color(0xff73B0EE)],
                                          ),
                                        ),
                                        LineChartBarData(
                                          spots: cpus.map((cpu) {
                                            return FlSpot(cpus.indexOf(cpu).toDouble(), cpu['user_load'].toDouble());
                                          }).toList(),
                                          isCurved: true,
                                          colors: [Color(0xffBAE050)],
                                          barWidth: 2,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: false,
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            colors: [Color(0xffBAE050)],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            curveType: CurveType.flat,
                            bevel: 10,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "利用率",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Spacer(),
                                      Text(
                                        "${cpus.last['user_load'] + cpus.last['system_load']} %",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${cpus.last['user_load']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                                    TextSpan(text: " %"),
                                                  ],
                                                ),
                                                style: TextStyle(color: Color(0xffBAE050)),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("用户"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${cpus.last['system_load']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                                    TextSpan(text: " %"),
                                                  ],
                                                ),
                                                style: TextStyle(color: Color(0xff73B0EE)),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("系统"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${cpus.last['other_load']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                                    TextSpan(text: " %"),
                                                  ],
                                                ),
                                                style: TextStyle(color: Color(0xff5584C8)),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text("I/O"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            curveType: CurveType.flat,
                            bevel: 10,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "负载平均",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${cpus.last['1min_load'] / 100}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                                    TextSpan(text: " %"),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("1分钟"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${cpus.last['5min_load'] / 100}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                                    TextSpan(text: " %"),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("5分钟"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${cpus.last['15min_load'] / 100}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                                    TextSpan(text: " %"),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text("15分钟"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: NeuCard(
                                curveType: CurveType.flat,
                                bevel: 20,
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                LineTooltipItem("利用率：${items[0].y}%", TextStyle(color: Colors.blue)),
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
                                          // getTitles: chartTitle,
                                          // getTitles: (value) {
                                          //   value = value / 1000 / 1000;
                                          //   return (value.floor() * 1000).toString();
                                          // },
                                          reservedSize: 28,
                                          interval: 10,
                                        ),
                                      ),
                                      minY: 0,
                                      maxY: 100,
                                      // maxY: 20,
                                      borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: memories.map((memory) {
                                            return FlSpot(memories.indexOf(memory).toDouble(), memory['real_usage'].toDouble());
                                          }).toList(),
                                          isCurved: true,
                                          colors: [Colors.blue],
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            curveType: CurveType.flat,
                            bevel: 10,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "利用率",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "${memories.last['real_usage']} %",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Spacer(),
                                      Text(
                                        "总计",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "${Util.formatSize(memories.last['memory_size'] * 1024, fixed: 0)}",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: "${Util.formatSize((memories.last['memory_size'] - memories.last['total_real']) * 1024, fixed: 1)}",
                                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("已保留"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: "${Util.formatSize(memories.last['real_usage'] * memories.last['memory_size'] * 10.24, fixed: 1)}",
                                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                                style: TextStyle(color: Colors.orange),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("已用"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${Util.formatSize(memories.last['buffer'] * 1024, fixed: 1)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                                style: TextStyle(color: Colors.lightBlue),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text("缓冲"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${Util.formatSize(memories.last['cached'] * 1024, fixed: 1)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                                style: TextStyle(color: Colors.cyan),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("缓存"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      NeuCard(
                                        width: (MediaQuery.of(context).size.width - 120) / 3,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        curveType: CurveType.flat,
                                        bevel: 10,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Column(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: "${Util.formatSize(memories.last['avail_real'] * 1024, fixed: 1)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                                style: TextStyle(color: Colors.green),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("可用"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          for (int i = 0; i < networkCount; i++)
                            NeuCard(
                              curveType: CurveType.flat,
                              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                              bevel: 20,
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      i == 0 ? "总计" : "局域网 $i",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  AspectRatio(
                                    aspectRatio: 1.70,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                      child: NeuCard(
                                        curveType: CurveType.flat,
                                        bevel: 20,
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                  getTitles: (v) {
                                                    return chartTitle(v, maxNetworkSpeed);
                                                  },
                                                  reservedSize: 28,
                                                  interval: chartInterval(maxNetworkSpeed),
                                                ),
                                              ),
                                              minY: 0,
                                              // maxY: 20,
                                              borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: networks.map((network) {
                                                    return FlSpot(networks.indexOf(network).toDouble(), network[i]['tx'].toDouble());
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
                                                    return FlSpot(networks.indexOf(network).toDouble(), network[i]['rx'].toDouble());
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
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.upload_sharp,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          Util.formatSize(networks.last[i]['tx']) + "/S",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        Spacer(),
                                        Icon(
                                          Icons.download_sharp,
                                          color: Colors.green,
                                        ),
                                        Text(
                                          Util.formatSize(networks.last[i]['rx']) + "/S",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      ListView(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                Label("总计", Colors.blue),
                                for (int i = 0; i < disks.last['disk'].length; i++)
                                  Label(
                                    "${disks.last['disk'][i]['display_name']}",
                                    colors[i],
                                    height: 22,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "利用率",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < disks.last['disk'].length; i++)
                                                        LineTooltipItem(
                                                          "${disks.last['disk'][i]['display_name']}：${disks[items[0].spotIndex]['disk'][i]['utilization'].floor()}%",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${disks[items[0].spotIndex]['total']['utilization'].floor()}%", TextStyle(color: Colors.blue)),
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
                                                // getTitles: chartTitle,
                                                // getTitles: (value) {
                                                //   value = value / 1000 / 1000;
                                                //   return (value.floor() * 1000).toString();
                                                // },
                                                reservedSize: 28,
                                                interval: 10,
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: 100,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: disks.map((disk) {
                                                  return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['utilization'].toDouble());
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
                                              ),
                                              for (int i = 0; i < disks.last['disk'].length; i++)
                                                LineChartBarData(
                                                  spots: disks.map((disk) {
                                                    return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['utilization'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "读取速度",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < disks.last['disk'].length; i++)
                                                        LineTooltipItem(
                                                          "${disks.last['disk'][i]['display_name']}：${Util.formatSize(disks[items[0].spotIndex]['disk'][i]['read_byte'].floor())}",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${Util.formatSize(disks[items[0].spotIndex]['total']['read_byte'].floor())}", TextStyle(color: Colors.blue)),
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
                                                getTitles: (v) {
                                                  return chartTitle(v, maxDiskReadSpeed);
                                                },
                                                reservedSize: 28,
                                                interval: chartInterval(maxDiskReadSpeed),
                                              ),
                                            ),
                                            minY: 0,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: disks.map((disk) {
                                                  return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['read_byte'].toDouble());
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
                                              ),
                                              for (int i = 0; i < disks.last['disk'].length; i++)
                                                LineChartBarData(
                                                  spots: disks.map((disk) {
                                                    return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['read_byte'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "写入速度",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < disks.last['disk'].length; i++)
                                                        LineTooltipItem(
                                                          "${disks.last['disk'][i]['display_name']}：${Util.formatSize(disks[items[0].spotIndex]['disk'][i]['write_byte'].floor())}",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${Util.formatSize(disks[items[0].spotIndex]['total']['write_byte'].floor())}", TextStyle(color: Colors.blue)),
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
                                                getTitles: (v) {
                                                  return chartTitle(v, maxDiskWriteSpeed);
                                                },
                                                reservedSize: 28,
                                                interval: chartInterval(maxDiskWriteSpeed),
                                              ),
                                            ),
                                            minY: 0,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: disks.map((disk) {
                                                  return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['write_byte'].toDouble());
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
                                              ),
                                              for (int i = 0; i < disks.last['disk'].length; i++)
                                                LineChartBarData(
                                                  spots: disks.map((disk) {
                                                    return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['write_byte'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "读取IOPS",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < disks.last['disk'].length; i++)
                                                        LineTooltipItem(
                                                          "${disks.last['disk'][i]['display_name']}：${disks[items[0].spotIndex]['disk'][i]['read_access'].floor()}",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${disks[items[0].spotIndex]['total']['read_access'].floor()}", TextStyle(color: Colors.blue)),
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
                                                // getTitles: (v) {
                                                //   return chartTitle(v, maxDiskReadAccess);
                                                // },
                                                reservedSize: 28,
                                                interval: 20,
                                              ),
                                            ),
                                            minY: 0,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: disks.map((disk) {
                                                  return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['read_access'].toDouble());
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
                                              ),
                                              for (int i = 0; i < disks.last['disk'].length; i++)
                                                LineChartBarData(
                                                  spots: disks.map((disk) {
                                                    return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['read_access'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "写入IOPS",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < disks.last['disk'].length; i++)
                                                        LineTooltipItem(
                                                          "${disks.last['disk'][i]['display_name']}：${Util.formatSize(disks[items[0].spotIndex]['disk'][i]['write_access'].floor())}",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${Util.formatSize(disks[items[0].spotIndex]['total']['write_access'].floor())}", TextStyle(color: Colors.blue)),
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
                                                reservedSize: 28,
                                                interval: 20,
                                              ),
                                            ),
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: disks.map((disk) {
                                                  return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['write_access'].toDouble());
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
                                              ),
                                              for (int i = 0; i < disks.last['disk'].length; i++)
                                                LineChartBarData(
                                                  spots: disks.map((disk) {
                                                    return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['write_access'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                Label("总计", Colors.blue),
                                for (int i = 0; i < spaces.last['volume'].length; i++)
                                  Label(
                                    "${spaces.last['volume'][i]['display_name']}",
                                    colors[i],
                                    height: 22,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "利用率",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < spaces.last['volume'].length; i++)
                                                        LineTooltipItem(
                                                          "${spaces.last['volume'][i]['display_name']}：${spaces[items[0].spotIndex]['volume'][i]['utilization'].floor()}%",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${spaces[items[0].spotIndex]['total']['utilization'].floor()}%", TextStyle(color: Colors.blue)),
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
                                                // getTitles: chartTitle,
                                                // getTitles: (value) {
                                                //   value = value / 1000 / 1000;
                                                //   return (value.floor() * 1000).toString();
                                                // },
                                                reservedSize: 28,
                                                interval: 10,
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: 100,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: spaces.map((volume) {
                                                  return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['utilization'].toDouble());
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
                                              ),
                                              for (int i = 0; i < spaces.last['volume'].length; i++)
                                                LineChartBarData(
                                                  spots: spaces.map((volume) {
                                                    return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['utilization'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "读取速度",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < spaces.last['volume'].length; i++)
                                                        LineTooltipItem(
                                                          "${spaces.last['volume'][i]['display_name']}：${Util.formatSize(spaces[items[0].spotIndex]['volume'][i]['read_byte'].floor())}",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${Util.formatSize(spaces[items[0].spotIndex]['total']['read_byte'].floor())}", TextStyle(color: Colors.blue)),
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
                                                getTitles: (v) {
                                                  return chartTitle(v, maxVolumeReadSpeed);
                                                },
                                                reservedSize: 28,
                                                interval: chartInterval(maxVolumeReadSpeed),
                                              ),
                                            ),
                                            minY: 0,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: spaces.map((volume) {
                                                  return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['read_byte'].toDouble());
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
                                              ),
                                              for (int i = 0; i < spaces.last['volume'].length; i++)
                                                LineChartBarData(
                                                  spots: spaces.map((volume) {
                                                    return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['read_byte'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "写入速度",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < spaces.last['volume'].length; i++)
                                                        LineTooltipItem(
                                                          "${spaces.last['volume'][i]['display_name']}：${Util.formatSize(spaces[items[0].spotIndex]['volume'][i]['write_byte'].floor())}",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${Util.formatSize(spaces[items[0].spotIndex]['total']['write_byte'].floor())}", TextStyle(color: Colors.blue)),
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
                                                getTitles: (v) {
                                                  return chartTitle(v, maxVolumeWriteSpeed);
                                                },
                                                reservedSize: 28,
                                                interval: chartInterval(maxVolumeWriteSpeed),
                                              ),
                                            ),
                                            minY: 0,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: spaces.map((volume) {
                                                  return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['write_byte'].toDouble());
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
                                              ),
                                              for (int i = 0; i < spaces.last['volume'].length; i++)
                                                LineChartBarData(
                                                  spots: spaces.map((volume) {
                                                    return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['write_byte'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "读取IOPS",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < spaces.last['volume'].length; i++)
                                                        LineTooltipItem(
                                                          "${spaces.last['volume'][i]['display_name']}：${spaces[items[0].spotIndex]['volume'][i]['read_access'].floor()}",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${spaces[items[0].spotIndex]['total']['read_access'].floor()}", TextStyle(color: Colors.blue)),
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
                                                // getTitles: (v) {
                                                //   return chartTitle(v, maxvolumeReadAccess);
                                                // },
                                                reservedSize: 28,
                                                interval: 20,
                                              ),
                                            ),
                                            minY: 0,
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: spaces.map((volume) {
                                                  return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['read_access'].toDouble());
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
                                              ),
                                              for (int i = 0; i < spaces.last['volume'].length; i++)
                                                LineChartBarData(
                                                  spots: spaces.map((volume) {
                                                    return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['read_access'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            curveType: CurveType.flat,
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "写入IOPS",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1.70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                                    child: NeuCard(
                                      curveType: CurveType.flat,
                                      bevel: 20,
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                      for (int i = 0; i < spaces.last['volume'].length; i++)
                                                        LineTooltipItem(
                                                          "${spaces.last['volume'][i]['display_name']}：${Util.formatSize(spaces[items[0].spotIndex]['volume'][i]['write_access'].floor())}",
                                                          TextStyle(color: colors[i]),
                                                        ),
                                                      LineTooltipItem("总计：${Util.formatSize(spaces[items[0].spotIndex]['total']['write_access'].floor())}", TextStyle(color: Colors.blue)),
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
                                                reservedSize: 28,
                                                interval: 20,
                                              ),
                                            ),
                                            // maxY: 20,
                                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: spaces.map((volume) {
                                                  return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['write_access'].toDouble());
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
                                              ),
                                              for (int i = 0; i < spaces.last['volume'].length; i++)
                                                LineChartBarData(
                                                  spots: spaces.map((volume) {
                                                    return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['write_access'].toDouble());
                                                  }).toList(),
                                                  isCurved: true,
                                                  colors: [
                                                    colors[i],
                                                  ],
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: false,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
