import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class WidgetSetting extends StatefulWidget {
  final List widgets;
  final Map restoreSizePos;
  WidgetSetting(this.widgets, this.restoreSizePos);
  @override
  _WidgetSettingState createState() => _WidgetSettingState();
}

class _WidgetSettingState extends State<WidgetSetting> {
  List<String> allWidgets = [
    // "SYNO.SDS.SystemInfoApp.FileChangeLogWidget",
    "SYNO.SDS.SystemInfoApp.SystemHealthWidget",
    "SYNO.SDS.ResourceMonitor.Widget",
    "SYNO.SDS.SystemInfoApp.StorageUsageWidget",
    "SYNO.SDS.SystemInfoApp.ConnectionLogWidget",
    "SYNO.SDS.TaskScheduler.TaskSchedulerWidget",
    "SYNO.SDS.SystemInfoApp.FileChangeLogWidget",
    "SYNO.SDS.SystemInfoApp.RecentLogWidget",
  ];
  Map name = {
    "SYNO.SDS.SystemInfoApp.FileChangeLogWidget": "文件更改日志",
    "SYNO.SDS.SystemInfoApp.RecentLogWidget": "最新日志",
    "SYNO.SDS.TaskScheduler.TaskSchedulerWidget": "计划任务",
    "SYNO.SDS.SystemInfoApp.SystemHealthWidget": "系统状况",
    "SYNO.SDS.SystemInfoApp.ConnectionLogWidget": "目前连接用户",
    "SYNO.SDS.SystemInfoApp.StorageUsageWidget": "存储",
    "SYNO.SDS.ResourceMonitor.Widget": "资源监控",
  };
  List showWidgets = [];
  List selectedWidgets = [];
  @override
  void initState() {
    setState(() {
      selectedWidgets.addAll(widget.widgets);
      showWidgets.addAll(widget.widgets);
    });
    allWidgets.forEach((widget) {
      if (!showWidgets.contains(widget)) {
        setState(() {
          showWidgets.add(widget);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("小组件设置"),
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
                List saveWidgets = [];
                showWidgets.forEach((widget) {
                  if (selectedWidgets.contains(widget)) {
                    saveWidgets.add(widget);
                  }
                });
                Map data = {
                  "SYNO.SDS._Widget.Instance": {"modulelist": saveWidgets},
                  // "restoreSizePos": widget.restoreSizePos
                };
                var res = await Api.userSetting(data);
                if (res['success']) {
                  Util.toast("保存小组件成功");
                  Navigator.of(context).pop(saveWidgets);
                } else {
                  Util.toast("保存小组件失败，代码${res['error']['code']}");
                }
              },
              child: Image.asset(
                "assets/icons/save.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
      body: ReorderableListView(
        padding: EdgeInsets.symmetric(vertical: 20),
        children: showWidgets.map((widget) {
          return NeuCard(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            curveType: CurveType.flat,
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            bevel: 20,
            key: ValueKey(widget),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name[widget],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedWidgets.contains(widget)) {
                          selectedWidgets.remove(widget);
                        } else {
                          selectedWidgets.add(widget);
                        }
                        print(showWidgets);
                      });
                    },
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      curveType: selectedWidgets.contains(widget) ? CurveType.emboss : CurveType.flat,
                      padding: EdgeInsets.all(5),
                      bevel: 5,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: selectedWidgets.contains(widget)
                            ? Icon(
                                CupertinoIcons.checkmark_alt,
                                color: Color(0xffff9813),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onReorder: (int oldIndex, int newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          var child = showWidgets.removeAt(oldIndex);
          showWidgets.insert(newIndex, child);

          setState(() {});
        },
      ),
    );
  }
}
