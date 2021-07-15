import 'package:dsm_helper/pages/resource_monitor/performance.dart';
import 'package:dsm_helper/pages/resource_monitor/task_manager.dart';
import 'package:dsm_helper/pages/resource_monitor/users.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class ResourceMonitor extends StatefulWidget {
  ResourceMonitor({this.tabIndex = 0});
  final int tabIndex;
  @override
  _ResourceMonitorState createState() => _ResourceMonitorState();
}

class _ResourceMonitorState extends State<ResourceMonitor> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("资源监控"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
            child: NeuButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return Performance();
                    },
                    settings: RouteSettings(name: "performance"),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      "assets/control_panel/performance.png",
                      width: 40,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        "性能",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
            child: NeuButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return TaskManager();
                    },
                    settings: RouteSettings(name: "task_manager"),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      "assets/control_panel/task_manager.png",
                      width: 40,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        "任务管理器",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
            child: NeuButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return Users();
                    },
                    settings: RouteSettings(name: "monitor_users"),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      "assets/control_panel/plugin.png",
                      width: 40,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        "目前连接用户",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
          //   child: NeuButton(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //         CupertinoPageRoute(
          //           builder: (context) {
          //             return SpeedLimit();
          //           },
          //           settings: RouteSettings(name: "speed_limit"),
          //         ),
          //       );
          //     },
          //     padding: EdgeInsets.zero,
          //     decoration: NeumorphicDecoration(
          //       color: Theme.of(context).scaffoldBackgroundColor,
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     bevel: 20,
          //     child: Padding(
          //       padding: EdgeInsets.symmetric(vertical: 20),
          //       child: Row(
          //         children: [
          //           SizedBox(
          //             width: 20,
          //           ),
          //           Image.asset(
          //             "assets/control_panel/speed.png",
          //             width: 40,
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Expanded(
          //             child: Text(
          //               "速度限制",
          //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          //             ),
          //           ),
          //           SizedBox(
          //             width: 20,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
          //   child: NeuButton(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //         CupertinoPageRoute(
          //           builder: (context) {
          //             return MonitorSetting();
          //           },
          //           settings: RouteSettings(name: "monitor_setting"),
          //         ),
          //       );
          //     },
          //     padding: EdgeInsets.zero,
          //     decoration: NeumorphicDecoration(
          //       color: Theme.of(context).scaffoldBackgroundColor,
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     bevel: 20,
          //     child: Padding(
          //       padding: EdgeInsets.symmetric(vertical: 20),
          //       child: Row(
          //         children: [
          //           SizedBox(
          //             width: 20,
          //           ),
          //           Image.asset(
          //             "assets/icons/setting.png",
          //             width: 40,
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Expanded(
          //             child: Text(
          //               "设置",gg
          //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          //             ),
          //           ),
          //           SizedBox(
          //             width: 20,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
