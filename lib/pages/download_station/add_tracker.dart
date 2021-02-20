import 'package:dsm_helper/util/function.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class AddTracker extends StatefulWidget {
  final String id;
  AddTracker(this.id);
  @override
  _AddTrackerState createState() => _AddTrackerState();
}

class _AddTrackerState extends State<AddTracker> {
  String tracker = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          NeuCard(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            bevel: 20,
            curveType: CurveType.flat,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: NeuTextField(
              onChanged: (v) => tracker = v,
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Tracker链接，每行一个',
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          NeuButton(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () async {
              List<String> temp = tracker.split("\n");
              List<String> trackers = [];
              temp.forEach((item) {
                if (item.trim() != "") {
                  trackers.add(item.trim());
                }
              });
              if (tracker.length == 0) {
                Util.toast("请填写Tacker");
                return;
              }
              var res = await Api.downloadTrackerAdd(widget.id, trackers);
              if (res['success']) {
                Util.toast("添加Tracker成功");
                Navigator.of(context).pop(true);
              } else {
                Util.toast("添加Tracker失败，代码${res['error']['code']}");
              }
            },
            child: Text(
              ' 创建 ',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
