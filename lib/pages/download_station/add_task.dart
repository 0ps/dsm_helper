import 'package:dsm_helper/pages/file/select_folder.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

class AddDownloadTask extends StatefulWidget {
  @override
  _AddDownloadTaskState createState() => _AddDownloadTaskState();
}

class _AddDownloadTaskState extends State<AddDownloadTask> {
  String saveFolder = "";
  String url = "";
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.downloadLocation();
    if (res['success']) {
      setState(() {
        saveFolder = res['data']['default_destination'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("创建下载任务"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          NeuButton(
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return SelectFolder(
                    multi: false,
                  );
                },
              ).then((res) {
                if (res != null && res.length == 1) {
                  setState(() {
                    saveFolder = res[0];
                  });
                }
              });
            },
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "保存位置",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      saveFolder == "" ? "选择保存位置" : saveFolder,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          NeuCard(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            bevel: 20,
            curveType: CurveType.flat,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: NeuTextField(
              onChanged: (v) => url = v,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: '下载链接',
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
              if (saveFolder == "") {
                Util.toast("请选择保存位置");
                Util.vibrate(FeedbackType.impact);
                return;
              }
              if (url.trim() == "") {
                Util.toast("请输入下载链接");
                Util.vibrate(FeedbackType.light);
                return;
              }
              var res = await Api.downloadTaskCreate(saveFolder, "url", url);
              if (res['success']) {
                Util.toast("创建任务成功");
                Navigator.of(context).pop(true);
              } else {
                Util.toast("创建任务失败，code：${res['error']['code']}");
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
