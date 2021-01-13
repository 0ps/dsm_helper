import 'package:dsm_helper/pages/control_panel/task_scheduler/task_record.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class TaskScheduler extends StatefulWidget {
  @override
  _TaskSchedulerState createState() => _TaskSchedulerState();
}

class _TaskSchedulerState extends State<TaskScheduler> {
  bool loading = true;
  List tasks = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.taskScheduler();
    if (res['success']) {
      setState(() {
        loading = false;
        tasks = res['data']['tasks'];
      });
    } else {
      Util.toast("加载失败");
      Navigator.of(context).pop();
    }
  }

  Widget _buildTaskItem(task) {
    task['running'] = task['running'] ?? false;
    task['set'] = task['set'] ?? false;
    return NeuCard(
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      bevel: 20,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Label(task['owner'], Colors.lightBlueAccent),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          task['name'],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(task['app_name'] != null ? task['app_name'] : "用户定义的脚本"),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "下次：${task['next_trigger_time']}",
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    task['action'],
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      task['set'] = true;
                    });
                    var res = await Api.taskEnable(task['id'], !task['enable']);
                    setState(() {
                      task['set'] = false;
                    });
                    if (res['success']) {
                      setState(() {
                        task['enable'] = !task['enable'];
                      });
                    } else {
                      Util.toast("操作失败，code：${res['error']['code']}");
                    }
                  },
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    curveType: task['enable'] ? CurveType.emboss : CurveType.flat,
                    padding: EdgeInsets.all(5),
                    bevel: 5,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: task['set']
                          ? CupertinoActivityIndicator()
                          : task['enable']
                              ? Icon(
                                  CupertinoIcons.checkmark_alt,
                                  color: Color(0xffff9813),
                                )
                              : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                if (task['type'] == 'script')
                  NeuButton(
                    onPressed: () async {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) {
                            return TaskRecord(task['id']);
                          },
                          settings: RouteSettings(name: "task_record")));
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
                        CupertinoIcons.list_bullet,
                        color: Color(0xffff9813),
                        size: 16,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 5,
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("任务计划"),
      ),
      body: loading
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              child: Center(
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
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemBuilder: (context, i) {
                return _buildTaskItem(tasks[i]);
              },
              itemCount: tasks.length,
            ),
    );
  }
}
