import 'package:dsm_helper/pages/file/select_folder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class AddDownloadTask extends StatefulWidget {
  @override
  _AddDownloadTaskState createState() => _AddDownloadTaskState();
}

class _AddDownloadTaskState extends State<AddDownloadTask> {
  String saveFolder = "";
  String url = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新建下载任务"),
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
        ],
      ),
    );
  }
}
