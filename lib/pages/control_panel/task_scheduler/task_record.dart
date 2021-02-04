import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class TaskRecord extends StatefulWidget {
  final int id;
  TaskRecord(this.id);
  @override
  _TaskRecordState createState() => _TaskRecordState();
}

class _TaskRecordState extends State<TaskRecord> {
  List records = [];
  bool loading = true;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.taskRecord(widget.id);
    if (res['success']) {
      setState(() {
        loading = false;
        records = res['data'];
      });
    } else {
      Util.toast("加载失败");
      Navigator.of(context).pop();
    }
  }

  Widget _buildRecordItem(record) {
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
                  Text(
                    "${record['start_time']} 至 ${record['stop_time']}",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "脚本：",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${record['script_in'].trim()}",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      if (record['exit_type'] == 'normal') Label("正常", Colors.green) else Label("中断(${record['exit_code']})", Colors.red),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "标准输出/结果：",
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${record['script_out'].trim()}",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
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
        title: Text("查看结果"),
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
                return _buildRecordItem(records[i]);
              },
              itemCount: records.length,
            ),
    );
  }
}
