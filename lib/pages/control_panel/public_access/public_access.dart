import 'dart:async';

import 'package:dsm_helper/pages/control_panel/public_access/edit_ddns.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class PublicAccess extends StatefulWidget {
  const PublicAccess({Key key}) : super(key: key);

  @override
  _PublicAccessState createState() => _PublicAccessState();
}

class _PublicAccessState extends State<PublicAccess> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List providers = [];
  List records = [];
  String nextUpdateTime = "";
  List ips = [];
  Timer timer;
  Map statusStr = {
    "service_ddns_normal": "正常",
    "service_ddns_error_unknown": "联机失败",
    "loading": "加载中",
    "disabled": "已停用",
  };
  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    getData();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
    var res = await Api.publicAccessInfo();
    if (res['success']) {
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.Core.DDNS.Provider":
              setState(() {
                providers = item['data']['providers'].where((e) => e['provider'].startsWith("USER_") || e['url'] == null).map((e) {
                  e['provider'] = e['provider'].replaceAll("USER_", "*");
                  return e;
                }).toList();
                providers.sort((a, b) {
                  return a['provider'].compareTo(b['provider']);
                });
              });
              break;
            case "SYNO.Core.DDNS.Record":
              setState(() {
                records = item['data']['records'].map((e) {
                  e['provider'] = e['provider'].replaceAll("USER_", "*");
                  return e;
                }).toList();
                nextUpdateTime = item['data']['next_update_time'];
              });
              break;
            case "SYNO.Core.DDNS.ExtIP":
              ips = item['data'];

              break;
          }
        }
      });
    }
  }

  Widget _buildDdnsItem(ddns) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return EditDdns(
            providers,
            ddns: ddns,
          );
        })).then((value) async {
          if (value != null && value) {
            await Api.ddnsUpdate(id: ddns['id'].replaceAll("USER_", "*"));
            getData();
          }
        });
      },
      child: NeuCard(
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        curveType: CurveType.flat,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        bevel: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${ddns['provider']}",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 5,
                ),
                Label(
                  statusStr[ddns['status']] ?? ddns['status'],
                  ddns['status'] == "service_ddns_normal" ? Colors.green : Colors.red,
                  fill: true,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text("${ddns['hostname']}"),
                SizedBox(
                  width: 10,
                ),
                Text("${ddns['ip']}"),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text("上次：${ddns['lastupdated'] == "disabled" ? "已停用" : ddns['lastupdated']}"),
              ],
            ),
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
        title: Text("外部访问"),
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
              onPressed: () async {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                  return EditDdns(
                    providers,
                    extIp: ips,
                  );
                }));
              },
              child: Icon(Icons.add),
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
              onPressed: () async {
                await Api.ddnsUpdate();
                getData();
              },
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // NeuCard(
          //   width: double.infinity,
          //   decoration: NeumorphicDecoration(
          //     color: Theme.of(context).scaffoldBackgroundColor,
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          //   curveType: CurveType.flat,
          //   bevel: 10,
          //   child: TabBar(
          //     isScrollable: false,
          //     controller: _tabController,
          //     indicatorSize: TabBarIndicatorSize.label,
          //     labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          //     unselectedLabelColor: Colors.grey,
          //     indicator: BubbleTabIndicator(
          //       indicatorColor: Theme.of(context).scaffoldBackgroundColor,
          //       shadowColor: Util.getAdjustColor(Theme.of(context).scaffoldBackgroundColor, -20),
          //     ),
          //     tabs: [
          //       Padding(
          //         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          //         child: Text("DDNS"),
          //       ),
          //       // Padding(
          //       //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          //       //   child: Text("路由器配置"),
          //       // ),
          //       // Padding(
          //       //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          //       //   child: Text("高级设置"),
          //       // ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  itemBuilder: (context, i) {
                    return _buildDdnsItem(records[i]);
                  },
                  itemCount: records.length,
                ),
                // Center(
                //   child: Text("开发中"),
                // ),
                // Center(
                //   child: Text("开发中"),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
