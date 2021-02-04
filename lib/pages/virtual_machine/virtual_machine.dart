import 'dart:async';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:neumorphic/neumorphic.dart';

class VirtualMachine extends StatefulWidget {
  @override
  _VirtualMachineState createState() => _VirtualMachineState();
}

class _VirtualMachineState extends State<VirtualMachine> {
  Timer timer;
  bool loading = true;
  bool hostLoading = true;
  bool guestLoading = true;
  bool repoLoading = true;
  Map<String, bool> powerLoading = {};
  var cluster;
  List hosts = [];
  List guests = [];
  List repos = [];
  int _currentIndex = 0;
  @override
  void initState() {
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

  power(guest, String action) async {
    // print(guest);
    // String title = "";
    // if (guest['has_agent']) {
    //   title = "确认操作";
    // } else {
    //   title = "所选虚拟机上未安装 Guest Agent，可能无法成功关闭。 是否确定要继续？";
    // }
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
                  action == "poweroff" ? "如果您强制关闭虚拟机，可能出现数据丟失或文件系统错误。是否确定继续？" : "如果您虚拟机上未安装Guest Agent，可能无法成功关闭，是否确定继续？",
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
                            powerLoading[guest['id']] = true;
                          });
                          var res = await Api.vmmPower(guest['id'], action);
                          if (res['success']) {
                            Util.toast("请求发送成功");
                            getGuests();
                          } else {
                            Util.toast("请求发送失败，代码：${res['error']['code']}");
                          }
                          setState(() {
                            powerLoading[guest['id']] = false;
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
  }

  getData() async {
    var res = await Api.cluster("get");
    if (res['success']) {
      if (mounted)
        setState(() {
          cluster = res['data'];
          loading = false;
        });
      if (_currentIndex == 0) {
        getHosts();
      } else if (_currentIndex == 1) {
        getGuests();
      } else if (_currentIndex == 2) {
        getRepos();
      }
    }
  }

  getHosts() async {
    var res = await Api.cluster("get_host");
    if (res['success']) {
      if (mounted)
        setState(() {
          hosts = res['data']['hosts'];
          hosts.sort((a, b) {
            return a['name'].compareTo(b['name']);
          });
          hostLoading = false;
        });
    }
  }

  getGuests() async {
    var res = await Api.cluster("get_guest");
    if (res['success']) {
      if (mounted)
        setState(() {
          guests = res['data']['guests'];
          guests.sort((a, b) {
            return a['name'].compareTo(b['name']);
          });
          guestLoading = false;
        });
    }
  }

  getRepos() async {
    var res = await Api.cluster("get_repo");
    if (res['success']) {
      if (mounted)
        setState(() {
          repos = res['data']['repos'];
          repos.sort((a, b) {
            return a['name'].compareTo(b['name']);
          });
          repoLoading = false;
        });
    }
  }

  Widget _buildNetworkItem(network, index) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text("局域网${index + 1}：")),
          Icon(
            Icons.upload_sharp,
            color: Colors.blue,
          ),
          Text(
            Util.formatSize(network['tx']) + "/S",
            style: TextStyle(color: Colors.blue),
          ),
          Spacer(),
          Icon(
            Icons.download_sharp,
            color: Colors.green,
          ),
          Text(
            Util.formatSize(network['rx']) + "/S",
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildHostItem(host) {
    List networks = host['nics'];
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      bevel: 20,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  host['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                host['type'] == "healthy"
                    ? Label("正常", Colors.green)
                    : host['type'] == "warning"
                        ? Label("警告", Colors.orange)
                        : Label("错误", Colors.red),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
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
                      currentValue: host['cpu_usage'],
                      displayText: '%',
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
                SizedBox(
                  width: 50,
                  child: Text("RAM："),
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
                      currentValue: host['ram_usage'],
                      displayText: '%',
                    ),
                  ),
                ),
              ],
            ),
            ...networks.map((network) {
              return _buildNetworkItem(network, networks.indexOf(network));
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestItem(guest) {
    if (powerLoading[guest['id']] == null) {
      powerLoading[guest['id']] = false;
    }
    List networks = guest['nics'];
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(bottom: 20),
      curveType: CurveType.flat,
      bevel: 20,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  guest['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                guest['type'] == "healthy"
                    ? (guest['status'] == "none"
                        ? Label(
                            "运行中",
                            Colors.green,
                            fill: true,
                          )
                        : guest['status'] == "shutdown"
                            ? Label("已关机", Colors.green)
                            : Label("正常", Colors.green))
                    : guest['type'] == "warning"
                        ? Label("警告", Colors.orange)
                        : Label("错误", Colors.red),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    if (powerLoading[guest['id']]) {
                      return;
                    }
                    if (guest['type'] == "healthy") {
                      if (guest['status'] == "none") {
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
                                    NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        power(guest, "shutdown");
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 5,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        "关机",
                                        style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 22,
                                    ),
                                    NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        power(guest, "poweroff");
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 5,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        "强制关机",
                                        style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 22,
                                    ),
                                    NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        power(guest, "reboot");
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
                        //开机
                        setState(() {
                          powerLoading[guest['id']] = true;
                        });
                        var check = await Api.checkPowerOn(guest['id']);
                        print(check);
                        if (check['success']) {
                          var res = await Api.vmmPower(guest['id'], "poweron");
                          if (res['success']) {
                            Util.toast("开机请求发送成功");
                            getGuests();
                          } else {
                            Util.toast("开机请求发送失败，代码：${res['error']['code']}");
                          }
                        } else {
                          Util.toast("无法开机");
                        }
                      }
                    } else {
                      Util.toast("虚拟机状态未知，无法操作");
                    }
                  },
                  child: NeuCard(
                    padding: EdgeInsets.all(10),
                    // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    // padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: guest['type'] == "healthy" ? (guest['status'] == "none" ? CurveType.emboss : CurveType.flat) : CurveType.convex,
                    bevel: 20,
                    child: powerLoading[guest['id']]
                        ? CupertinoActivityIndicator()
                        : Image.asset(
                            "assets/icons/shutdown.png",
                            width: 20,
                          ),
                  ),
                ),
              ],
            ),
            if (guest['status'] != "shutdown") ...[
              SizedBox(
                height: 20,
              ),
              Row(
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
                        currentValue: guest['cpu_usage'] ~/ 10,
                        displayText: '.${guest['cpu_usage'] % 10}%',
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
                  SizedBox(
                    width: 50,
                    child: Text("RAM："),
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
                        currentValue: guest['ram_usage'] ~/ 100,
                        displayText: '.${(guest['ram_usage'] % 100).toString().padLeft(2, "0")}%',
                      ),
                    ),
                  ),
                ],
              ),
              ...networks.map((network) {
                return _buildNetworkItem(network, networks.indexOf(network));
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRepoItem(repo) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      margin: EdgeInsets.only(bottom: 20),
      bevel: 20,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  repo['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                repo['type'] == "healthy"
                    ? Label("正常", Colors.green)
                    : repo['type'] == "warning"
                        ? Label(repo['status'] == "provision_warning" ? "空间不足" : repo['status'], Colors.orange)
                        : Label("${repo['status']}", Colors.red),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text(
                    Util.formatSize(int.parse(repo['used'])),
                    style: TextStyle(color: Colors.blue),
                  ),
                  Text(
                    " / ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    Util.formatSize(int.parse(repo['size'])),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
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
                      currentValue: ((int.parse(repo['used']) / int.parse(repo['size'])) * 100).floor(),
                      displayText: '%',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("Virtual Machine Manager"),
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                    getHosts();
                  },
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: CurveType.flat,
                    margin: EdgeInsets.all(20),
                    bevel: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              curveType: _currentIndex == 0 ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(10),
                              bevel: 20,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("主机"),
                                      Spacer(),
                                      Text("${cluster['host_summ']['error'] + cluster['host_summ']['healthy'] + cluster['host_summ']['warning']}"),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (cluster['host_summ']['error'] > 0)
                                    Text(
                                      "${cluster['host_summ']['error']}",
                                      style: TextStyle(fontSize: 40, color: Colors.red),
                                    )
                                  else if (cluster['host_summ']['warning'] > 0)
                                    Text(
                                      "${cluster['host_summ']['warning']}",
                                      style: TextStyle(fontSize: 40, color: Colors.orange),
                                    )
                                  else
                                    Text(
                                      "${cluster['host_summ']['healthy']}",
                                      style: TextStyle(fontSize: 40, color: Colors.green),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = 1;
                                });
                                getGuests();
                              },
                              child: NeuCard(
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                curveType: _currentIndex == 1 ? CurveType.emboss : CurveType.flat,
                                padding: EdgeInsets.all(10),
                                bevel: 20,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("虚拟机"),
                                        Spacer(),
                                        Text("${cluster['guest_summ']['error'] + cluster['guest_summ']['healthy'] + cluster['guest_summ']['warning']}"),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    if (cluster['guest_summ']['error'] > 0)
                                      Text(
                                        "${cluster['guest_summ']['error']}",
                                        style: TextStyle(fontSize: 40, color: Colors.red),
                                      )
                                    else if (cluster['guest_summ']['warning'] > 0)
                                      Text(
                                        "${cluster['guest_summ']['warning']}",
                                        style: TextStyle(fontSize: 40, color: Colors.orange),
                                      )
                                    else
                                      Text(
                                        "${cluster['guest_summ']['healthy']}",
                                        style: TextStyle(fontSize: 40, color: Colors.green),
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
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = 2;
                                });
                                getRepos();
                              },
                              child: NeuCard(
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                curveType: _currentIndex == 2 ? CurveType.emboss : CurveType.flat,
                                padding: EdgeInsets.all(10),
                                bevel: 20,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("存储"),
                                        Spacer(),
                                        Text("${cluster['repo_summ']['error'] + cluster['repo_summ']['healthy'] + cluster['repo_summ']['warning']}"),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    if (cluster['repo_summ']['error'] > 0)
                                      Text(
                                        "${cluster['repo_summ']['error']}",
                                        style: TextStyle(fontSize: 40, color: Colors.red),
                                      )
                                    else if (cluster['repo_summ']['warning'] > 0)
                                      Text(
                                        "${cluster['repo_summ']['warning']}",
                                        style: TextStyle(fontSize: 40, color: Colors.orange),
                                      )
                                    else
                                      Text(
                                        "${cluster['repo_summ']['healthy']}",
                                        style: TextStyle(fontSize: 40, color: Colors.green),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      hostLoading
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
                          : ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemBuilder: (context, i) {
                                return _buildHostItem(hosts[i]);
                              },
                              itemCount: hosts.length,
                            ),
                      guestLoading
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
                          : ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemBuilder: (context, i) {
                                return _buildGuestItem(guests[i]);
                              },
                              itemCount: guests.length,
                            ),
                      repoLoading
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
                          : ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemBuilder: (context, i) {
                                return _buildRepoItem(repos[i]);
                              },
                              itemCount: repos.length,
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
