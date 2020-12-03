import 'dart:async';

import 'package:file_station/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Timer timer;
  Map utilization;
  List volumes;
  List connectedUsers;
  bool loading = true;
  bool success = true;
  String msg = "";
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.systemInfo();
    setState(() {
      loading = false;
      success = res['success'];
    });
    if (res['success']) {
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['api'] == "SYNO.Core.System.Utilization") {
          setState(() {
            utilization = item['data'];
          });
        } else if (item['api'] == "SYNO.Core.System") {
          setState(() {
            volumes = item['data']['vol_info'];
          });
        } else if (item['api'] == "SYNO.Core.CurrentConnection") {
          setState(() {
            connectedUsers = item['data']['items'];
          });
        }
        // else if(item['api'] == ""){
        //
        // }
      });
      if (timer == null) {
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      bevel: 5,
      child: Row(
        children: [
          Expanded(child: Text("${user['who']}")),
          Expanded(child: Text("${user['type']}")),
          Expanded(child: Text("${user['time']}")),
          Icon(
            Icons.remove_circle_outline,
            color: Colors.redAccent,
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
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      bevel: 5,
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("${volume['name'].toString().replaceFirst("volume_", "存储空间 ")}")),
          Expanded(flex: 2, child: Text("${Util.formatSize(int.parse(volume['used_size']))}/${Util.formatSize(int.parse(volume['total_size']))}")),
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
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CupertinoActivityIndicator(
                  radius: 14,
                ),
              ),
            )
          : success
              ? ListView(
                  children: [
                    SizedBox(
                      height: 2,
                    ),
                    NeuCard(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      bevel: 10,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.monitor),
                              Text("系统状态"),
                            ],
                          ),
                          Row(
                            children: [
                              Text("系统名称"),
                              Text("DiskStation"),
                            ],
                          ),
                          Row(
                            children: [
                              Text("运行时间"),
                              Text("2天 2:10:00"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    NeuCard(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      bevel: 10,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.monitor),
                              Text("登录用户"),
                            ],
                          ),
                          ...connectedUsers.map(_buildUserItem).toList(),
                        ],
                      ),
                    ),
                    NeuCard(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      bevel: 10,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.monitor),
                              Text("存储"),
                            ],
                          ),
                          ...volumes.map(_buildVolumeItem).toList(),
                        ],
                      ),
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
