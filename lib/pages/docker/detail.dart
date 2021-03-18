import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class ContainerDetail extends StatefulWidget {
  final String name;
  ContainerDetail(this.name);
  @override
  _ContainerDetailState createState() => _ContainerDetailState();
}

class _ContainerDetailState extends State<ContainerDetail> with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollController = ScrollController();
  bool loading = true;
  List ports = [];
  List networks = [];
  List links = [];
  List envs = [];
  String cmd = "";
  List volumes = [];
  int memory = 0;
  double memoryPercent = 0;
  int cpuPriority = 0;
  String status = "";
  int upTime = 0;
  Map shortcut;
  List logDates = [];
  List logs = [];
  String selectedDate = "";
  List processes = [];
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.dockerDetail(widget.name, "get");
    if (res['success']) {
      setState(() {
        loading = false;
        ports = res['data']['profile']['port_bindings'];
        networks = res['data']['profile']['network'];
        volumes = res['data']['profile']['volume_bindings'];
        envs = res['data']['profile']['env_variables'];
        memory = res['data']['profile']['memory_limit'];
        shortcut = res['data']['profile']['shortcut'];
        cpuPriority = res['data']['profile']['cpu_priority'];
        links = res['data']['profile']['links'];
        memoryPercent = res['data']['details']['memoryPercent'] * 1.0;

        upTime = res['data']['details']['up_time'];
        status = res['data']['details']['status'];
        cmd = res['data']['details']['exe_cmd'];
      });

      var process = await Api.dockerDetail(widget.name, "get_process");
      if (process['success']) {
        setState(() {
          processes = process['data']['processes'];
        });
      }
      getLogDates();
    } else {
      Util.toast("获取详情失败");
    }
  }

  getLogDates() async {
    var res = await Api.dockerLog(widget.name, "get_date_list");
    if (res['success']) {
      setState(() {
        logDates = res['data']['dates'];
        if (logDates.length > 0) {
          selectedDate = logDates[0];
        }
      });

      getLog();
    }
  }

  getLog() async {
    var log = await Api.dockerLog(widget.name, "get", date: selectedDate);
    if (log['success']) {
      setState(() {
        logs = log['data']['logs'];
      });
    }
  }

  Widget _buildPortItem(port) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${port['host_port']}",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "${port['container_port']}",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "${port['type']}",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeItem(volume) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "${volume['host_volume_file']}",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${volume['mount_point']}",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "${volume['type']}",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(link) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${link['link_container']}",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "${link['alias']}",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkItem(network) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${network['name']}",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "${network['driver']}",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvItem(env) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Text(
            "${env['key']}：",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              "${env['value']}",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessItem(process) {
    return NeuCard(
      width: double.infinity,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20),
      curveType: CurveType.flat,
      bevel: 10,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "进程：${process['pid']}",
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    "CPU：${process['cpu']}%",
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    "RAM：${Util.formatSize(process['memory'], fixed: 0)}",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(process['command']),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(log) {
    return NeuCard(
      width: double.infinity,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      bevel: 10,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Label("${log['stream']}", Colors.lightGreen),
                Spacer(),
                Text(
                  "${log['created']}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(log['text']),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(date) {
    String str = date;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
        getLog();
      },
      child: NeuCard(
        width: double.infinity,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        curveType: date == selectedDate ? CurveType.emboss : CurveType.flat,
        bevel: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            children: [
              Text(
                "${str.substring(5)}",
              ),
              Text(
                "${str.substring(0, 4)}",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(widget.name),
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
                    isScrollable: false,
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
                        child: Text("总览"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("进程"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("日志"),
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
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "基本信息",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text("启动时间："),
                                      Expanded(
                                        child: Text(
                                          DateTime.fromMillisecondsSinceEpoch(upTime * 1000).timeAgo,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text("快捷方式："),
                                      Expanded(
                                        child: Text(
                                          shortcut['enable_shortcut']
                                              ? (shortcut['enable_status_page']
                                                  ? "状态页面"
                                                  : shortcut['enable_web_page']
                                                      ? shortcut['web_page_url']
                                                      : "")
                                              : "无",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text("CPU优先顺序："),
                                      Expanded(
                                        child: Text(
                                          cpuPriority > 50
                                              ? "高"
                                              : cpuPriority == 50
                                                  ? "中"
                                                  : cpuPriority < 50
                                                      ? "低"
                                                      : "",
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text("内存限制："),
                                      Expanded(
                                        child: Text(
                                          memory > 0 ? Util.formatSize(memory) : "自动",
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text("执行命令："),
                                      Expanded(
                                        child: Text(
                                          cmd,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "端口设置",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "本地端口",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "容器端口",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "类型",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...ports.map(_buildPortItem).toList(),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "卷",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "文件/文件夹",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "装载路径",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "类型",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...volumes.map(_buildVolumeItem).toList(),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "链接",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "容器名称",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "别名",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...links.map(_buildLinkItem).toList(),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "网络",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "网络名称",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "驱动程序",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...networks.map(_buildNetworkItem).toList(),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "环境变量",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  ...envs.map(_buildEnvItem).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView.separated(
                          itemBuilder: (context, i) {
                            return _buildProcessItem(processes[i]);
                          },
                          separatorBuilder: (context, i) {
                            return SizedBox(
                              height: 20,
                            );
                          },
                          itemCount: processes.length),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoScrollbar(
                              child: ListView.separated(
                                padding: EdgeInsets.only(left: 20, right: 10, top: 20),
                                itemBuilder: (context, i) {
                                  return _buildDateItem(logDates[i]);
                                },
                                separatorBuilder: (context, i) {
                                  return SizedBox(
                                    height: 20,
                                  );
                                },
                                itemCount: logDates.length,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: DraggableScrollbar.semicircle(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              scrollbarTimeToFade: Duration(seconds: 1),
                              controller: _scrollController,
                              child: ListView.separated(
                                controller: _scrollController,
                                padding: EdgeInsets.only(left: 10, right: 20, top: 20),
                                itemBuilder: (context, i) {
                                  return _buildLogItem(logs.reversed.toList()[i]);
                                },
                                separatorBuilder: (context, i) {
                                  return SizedBox(
                                    height: 20,
                                  );
                                },
                                itemCount: logs.length,
                              ),
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
