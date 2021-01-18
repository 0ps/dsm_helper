import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:neumorphic/neumorphic.dart';

class Docker extends StatefulWidget {
  @override
  _DockerState createState() => _DockerState();
}

class _DockerState extends State<Docker> {
  List containers = [];
  Map<String, bool> powerLoading = {};
  Map utilization;
  bool loading = true;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.dockerInfo();
    setState(() {
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
              });
              break;
            case "SYNO.Docker.Container":
              setState(() {
                containers = item['data']['containers'];
              });
              break;
            case "SYNO.Docker.Container.Resource":
              List resources = item['data']['resources'];
              resources.forEach((resource) {
                containers.forEach((container) {
                  if (resource['name'] == container['name']) {
                    setState(() {
                      container['cpu'] = resource['cpu'];
                      container['memory'] = resource['memory'];
                      container['memoryPercent'] = resource['memoryPercent'];
                    });
                  }
                });
              });
              break;
          }
        }
      });
    }
  }

  power(container, String action, {bool preserveProfile}) async {
    if (action == "signal" || action == "delete") {
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
                    "确认操作",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    action == "signal"
                        ? "是否确定要强制停止容器？所有未保存的数据将丢失！"
                        : preserveProfile
                            ? "容器 ${container['name']} 将被清除。清除后，容器中的所有数据将丢失。是否确定继续？"
                            : "容器 ${container['name']} 将被删除。删除后，容器中的所有数据将丢失。是否确定继续？",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
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
                              powerLoading[container['id']] = true;
                            });
                            var res = await Api.dockerPower(container['name'], action, preserveProfile: preserveProfile);
                            if (res['success']) {
                              Util.toast("请求发送成功");
                              getData();
                            } else {
                              Util.toast("请求发送失败，代码：${res['error']['code']}");
                            }
                            setState(() {
                              powerLoading[container['id']] = false;
                            });
                          },
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          bevel: 5,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "确认",
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
      setState(() {
        powerLoading[container['id']] = true;
      });
      var res = await Api.dockerPower(container['name'], action);
      if (res['success']) {
        Util.toast("请求发送成功");
        getData();
      } else {
        Util.toast("请求发送失败，代码：${res['error']['code']}");
      }
      setState(() {
        powerLoading[container['id']] = false;
      });
    }
  }

  Widget _buildContainerItem(container) {
    if (powerLoading[container['id']] == null) {
      powerLoading[container['id']] = false;
    }
    return NeuCard(
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            container['name'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          container['status'] == "running"
                              ? Label("运行中", Colors.green)
                              : container['status'] == "stopped"
                                  ? Label("已停止", Colors.red)
                                  : Label(container['status'], Colors.orange),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(container['image']),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (container['status'] == "running") Text(DateTime.fromMillisecondsSinceEpoch(container['up_time'] * 1000).timeAgo),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    if (powerLoading[container['id']]) {
                      return;
                    }

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
                                  "选择操作",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                if (container['status'] == "stopped") ...[
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      power(container, "start");
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "启动",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 22,
                                  ),
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      power(container, "delete", preserveProfile: true);
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "清除",
                                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 22,
                                  ),
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      power(container, "delete", preserveProfile: false);
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "删除",
                                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                    ),
                                  ),
                                ] else ...[
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      power(container, "stop");
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "停止",
                                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 22,
                                  ),
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      power(container, "signal");
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "强制停止",
                                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 22,
                                  ),
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      power(container, "restart");
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "重新启动",
                                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: NeuCard(
                    padding: EdgeInsets.all(10),
                    // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    // padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: container['status'] == "running" ? CurveType.emboss : CurveType.flat,
                    bevel: 20,
                    child: powerLoading[container['id']]
                        ? CupertinoActivityIndicator()
                        : Image.asset(
                            "assets/icons/shutdown.png",
                            width: 20,
                          ),
                  ),
                ),
              ],
            ),
            if (container['status'] == "running") ...[
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("CPU"),
                            Spacer(),
                            Text(
                              "${container['cpu'].toStringAsFixed(2)}%",
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        NeuCard(
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
                            size: 10,
                            currentValue: (container['cpu']).ceil(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("内存"),
                            Spacer(),
                            Text(
                              "${Util.formatSize(container['memory'], fixed: 0)}",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        NeuCard(
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
                            progressColor: Colors.green,
                            size: 10,
                            currentValue: container['memoryPercent'].ceil(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Docker"),
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
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: NeuCard(
                        curveType: CurveType.flat,
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        bevel: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/cpu.png",
                                    width: 50,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "CPU",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              NeuCard(
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: NeuCard(
                        curveType: CurveType.flat,
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        bevel: 20,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/ram.png",
                                    width: 50,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "内存",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              NeuCard(
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                ...containers.map(_buildContainerItem).toList(),
              ],
            ),
    );
  }
}
