import 'dart:async';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';

class FileDetail extends StatefulWidget {
  final Map file;
  FileDetail(this.file);
  @override
  _FileDetailState createState() => _FileDetailState();
}

class _FileDetailState extends State<FileDetail> {
  Timer timer;
  bool loadingSize = true;
  int size = 0;
  int folderCount = 0;
  int fileCount = 0;
  @override
  void initState() {
    getDirSize();
    super.initState();
  }

  @override
  dispose() {
    timer?.cancel();
    super.dispose();
  }

  getDirSize() async {
    var task = await Api.dirSizeTask(widget.file['path']);
    if (task['success']) {
      timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        var result = await Api.dirSizeResult(task['data']['taskid']);
        print(result);
        if (result['success'] && result['data']['finished']) {
          timer.cancel();
          setState(() {
            loadingSize = false;
            size = result['data']['total_size'];
            folderCount = result['data']['num_dir'];
            fileCount = result['data']['num_file'];
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(
          widget.file['name'],
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          NeuCard(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.all(20),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            curveType: CurveType.flat,
            bevel: 20,
            child: Row(
              children: [
                Text("名称："),
                Expanded(
                  child: Text(widget.file['name']),
                ),
              ],
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
              child: Row(
                children: [
                  Text("位置："),
                  Expanded(
                    child: Text(
                      widget.file['path'],
                    ),
                  ),
                  NeuButton(
                    onPressed: () async {
                      ClipboardData data = new ClipboardData(text: widget.file['path']);
                      Clipboard.setData(data);
                      Util.toast("已复制到剪贴板");
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
                        Icons.copy,
                        color: Color(0xffff9813),
                        size: 16,
                      ),
                    ),
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
              child: Row(
                children: [
                  Text("路径："),
                  Expanded(
                    child: Text(
                      "${widget.file['additional']['real_path']}",
                    ),
                  ),
                  NeuButton(
                    onPressed: () async {
                      ClipboardData data = new ClipboardData(text: widget.file['additional']['real_path']);
                      Clipboard.setData(data);
                      Util.toast("已复制到剪贴板");
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
                        Icons.copy,
                        color: Color(0xffff9813),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          NeuCard(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.all(20),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            curveType: CurveType.flat,
            bevel: 20,
            child: Row(
              children: [Text("大小："), loadingSize ? CupertinoActivityIndicator() : Text(Util.formatSize(size))],
            ),
          ),
          if (widget.file['isdir'])
            NeuCard(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              curveType: CurveType.flat,
              bevel: 20,
              child: Row(
                children: [Text("包含："), loadingSize ? CupertinoActivityIndicator() : Text("$folderCount个文件夹，$fileCount个文件")],
              ),
            ),
          NeuCard(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.all(20),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            curveType: CurveType.flat,
            bevel: 20,
            child: Row(
              children: [Text("创建时间："), Text(DateTime.fromMillisecondsSinceEpoch(widget.file['additional']['time']['ctime'] * 1000).format("Y-m-d H:i:s"))],
            ),
          ),
          NeuCard(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.all(20),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            curveType: CurveType.flat,
            bevel: 20,
            child: Row(
              children: [Text("修改时间："), Text(DateTime.fromMillisecondsSinceEpoch(widget.file['additional']['time']['mtime'] * 1000).format("Y-m-d H:i:s"))],
            ),
          ),
        ],
      ),
    );
  }
}
