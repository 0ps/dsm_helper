import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/strings.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Notify extends StatefulWidget {
  final List notifies;
  Notify(this.notifies);
  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildNotifyItem(notify) {
    // print(widget.strings[notify['className']]['common']['displayname']);
    String msg = notify['msg'].toString();
    print(notify);
    String title = "";
    List<String> titles = notify['title'].split(":");
    //判断是否在string内
    if (webManagerStrings[titles[0]] != null && webManagerStrings[titles[0]][titles[1]] != null) {
      if (webManagerStrings[titles[0]][titles[1]] != null) {
        title = webManagerStrings[titles[0]][titles[1]];
      }
    } else if (Util.strings[notify['className']] != null) {
      if (Util.strings[notify['className']][titles[0]] != null && Util.strings[notify['className']][titles[0]][titles[1]] != null) {
        title = Util.strings[notify['className']][titles[0]][titles[1]];
      } else if (Util.strings[notify['className']] != null && Util.strings[notify['className']]['common'] != null && Util.strings[notify['className']]['common']['displayname'] != null) {
        title = Util.strings[notify['className']]['common']['displayname'];
      }
    } else {
      title = notify['className'] == "" ? notify['title'] : notify['className'];
    }
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      bevel: 10,
      curveType: CurveType.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateTime.fromMillisecondsSinceEpoch(notify['time'] * 1000).timeAgo,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          NeuCard(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            bevel: 10,
            curveType: CurveType.flat,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    msg,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(
          "消息",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.notifies.length > 0
                ? ListView(
                    children: widget.notifies.map(_buildNotifyItem).toList(),
                  )
                : Center(
                    child: Text("暂无消息"),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: NeuButton(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () async {
                      var res = await Api.clearNotify();
                      if (res['success']) {
                        Util.toast("清除成功");
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text("全部清除"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
