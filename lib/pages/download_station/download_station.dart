import 'dart:async';

import 'package:dsm_helper/pages/download_station/add_task.dart';
import 'package:dsm_helper/pages/download_station/detail.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:neumorphic/neumorphic.dart';

class DownloadStation extends StatefulWidget {
  @override
  _DownloadStationState createState() => _DownloadStationState();
}

class _DownloadStationState extends State<DownloadStation> {
  bool loading = true;
  Timer timer;
  List tasks = [];
  int downloadRate = 0;
  int uploadRate = 0;
  Map<String, bool> pauseLoading = {};
  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  getData() async {
    var res = await Api.downloadStationInfo();
    if (!mounted) {
      return;
    }
    if (timer == null) {
      timer = Timer.periodic(Duration(seconds: 10), (timer) {
        getData();
      });
    }
    setState(() {
      loading = false;
    });
    if (res['success']) {
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.DownloadStation2.Task":
              setState(() {
                tasks = item['data']['task'];
              });
              break;
            case "SYNO.DownloadStation2.Task.Statistic":
              setState(() {
                downloadRate = item['data']['download_rate'];
                uploadRate = item['data']['upload_rate'];
              });
              break;
          }
        }
      });
    }
  }

  Widget _buildDownloadItem(download) {
    pauseLoading[download['id']] = pauseLoading[download['id']] ?? false;
    FileType fileType = Util.fileType(download['title']);
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
          CupertinoPageRoute(
            builder: (context) {
              return DownloadDetail(download['id']);
            },
            settings: RouteSettings(name: "download_detail"),
          ),
        )
            .then((res) {
          if (res != null && res) {
            getData();
          }
        });
      },
      child: NeuCard(
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 20,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  FileIcon(fileType),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      "${download['title']}",
                      style: TextStyle(fontSize: 16),
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 35,
                    child: download['status'] == 2 || download['status'] == 3 || download['status'] > 100
                        ? GestureDetector(
                            onTap: () async {
                              setState(() {
                                pauseLoading[download['id']] = true;
                              });
                              var res = await Api.downloadTaskAction([download['id']], download['status'] == 2 ? "pause" : "resume");
                              setState(() {
                                pauseLoading[download['id']] = false;
                              });
                              if (res['success']) {
                                getData();
                              }
                            },
                            child: NeuCard(
                              padding: EdgeInsets.all(5),
                              // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              // padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              curveType: download['status'] == 2 ? CurveType.emboss : CurveType.flat,
                              bevel: 20,
                              child: pauseLoading[download['id']]
                                  ? CupertinoActivityIndicator()
                                  : Icon(
                                      download['status'] == 2 ? Icons.pause_circle_outline_sharp : Icons.play_circle_outline_sharp,
                                      color: download['status'] == 2 ? Colors.red : Colors.green,
                                    ),
                            ),
                          )
                        : Container(
                            // child: Text("${download['status']}"),
                            ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (download['status'] != 5)
                            TextSpan(
                              text: "${Util.formatSize(download['additional']['transfer']['size_downloaded'])} / ",
                              style: TextStyle(fontSize: 12, color: Colors.lightBlueAccent),
                            ),
                          TextSpan(
                            text: "${Util.formatSize(download['size'])}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (download['status'] == 2)
                    Expanded(
                      child: Text(
                        "${download['additional']['transfer']['speed_download'] > 0 ? Util.timeRemaining(((download['size'] - download['additional']['transfer']['size_downloaded']) / download['additional']['transfer']['speed_download']).ceil()) : "--:--:--"}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  Expanded(
                    child: download['status'] == 1
                        ? Text(
                            "等待中",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.right,
                          )
                        : download['status'] == 2
                            ? Text(
                                "${Util.formatSize(download['additional']['transfer']['speed_download'])}/s",
                                style: TextStyle(fontSize: 12, color: Colors.lightBlueAccent),
                                textAlign: TextAlign.right,
                              )
                            : download['status'] == 3
                                ? Text(
                                    "已暂停",
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                    textAlign: TextAlign.right,
                                  )
                                : download['status'] == 5
                                    ? Text(
                                        "已完成",
                                        style: TextStyle(fontSize: 12, color: Colors.green),
                                        textAlign: TextAlign.right,
                                      )
                                    : download['status'] == 6
                                        ? Text(
                                            "检查中",
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                            textAlign: TextAlign.right,
                                          )
                                        : download['status'] == 8
                                            ? Text(
                                                "做种中",
                                                style: TextStyle(fontSize: 12, color: Colors.greenAccent),
                                                textAlign: TextAlign.right,
                                              )
                                            : download['status'] == 11
                                                ? Text(
                                                    "等待中",
                                                    style: TextStyle(fontSize: 12, color: Colors.blue),
                                                    textAlign: TextAlign.right,
                                                  )
                                                : download['status'] == 101
                                                    ? Text(
                                                        "错误",
                                                        style: TextStyle(fontSize: 12, color: Colors.red),
                                                        textAlign: TextAlign.right,
                                                      )
                                                    : download['status'] == 105
                                                        ? Text(
                                                            "空间不足",
                                                            style: TextStyle(fontSize: 12, color: Colors.red),
                                                            textAlign: TextAlign.right,
                                                          )
                                                        : download['status'] == 113
                                                            ? Text(
                                                                "重复的任务",
                                                                style: TextStyle(fontSize: 12, color: Colors.red),
                                                                textAlign: TextAlign.right,
                                                              )
                                                            : Text(
                                                                "代码：${download['status']}",
                                                                style: TextStyle(fontSize: 12, color: Colors.red),
                                                                textAlign: TextAlign.right,
                                                              ),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              FAProgressBar(
                backgroundColor: Color(0xffE0E0E0),
                progressColor: Colors.blue,
                size: 6,
                currentValue: download['size'] == 0 ? 0 : (download['additional']['transfer']['size_downloaded'] / download['size'] * 100).ceil(),
              )
              // download['status'] == 5
              //     ? Label("完成", Colors.green)
              //     : download['status'] == 2
              //         ? Label(download['size'] == 0 ? "下载中" : "${(download['additional']['transfer']['size_downloaded'] / download['size'] * 100).toStringAsFixed(2)}%", Colors.lightBlueAccent)
              //         : download['status'] == 3
              //             ? Label("暂停", Colors.orange)
              //             : Label("${download['status']}", Colors.red),
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
        title: downloadRate > 0 || uploadRate > 0
            ? Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_sharp,
                    size: 20,
                    color: Colors.lightBlueAccent,
                  ),
                  Text(
                    Util.formatSize(downloadRate),
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.upload_sharp,
                    size: 20,
                    color: Colors.orange,
                  ),
                  Text(
                    Util.formatSize(uploadRate),
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                  ),
                ],
              )
            : Text("Download Station"),
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
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return AddDownloadTask();
                    },
                    settings: RouteSettings(name: "add_download_task"),
                  ),
                );
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
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
          : tasks.length > 0
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.all(20),
                        itemBuilder: (context, i) {
                          return _buildDownloadItem(tasks[i]);
                        },
                        itemCount: tasks.length,
                        separatorBuilder: (context, i) {
                          return SizedBox(
                            height: 20,
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text("暂无下载任务"),
                ),
    );
  }
}
