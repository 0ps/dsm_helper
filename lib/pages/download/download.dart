import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:dsm_helper/pages/download/download_setting.dart';
import 'package:extended_image/extended_image.dart';
import 'package:dsm_helper/pages/common/preview.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neumorphic/neumorphic.dart';

class Download extends StatefulWidget {
  Download({key}) : super(key: key);
  @override
  DownloadState createState() => DownloadState();
}

class DownloadState extends State<Download> {
  List<DownloadTask> tasks = [];
  bool loading = true;
  List<DownloadTask> selectedTasks = [];
  Timer timer;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    tasks = await FlutterDownloader.loadTasks();
    setState(() {
      loading = false;
    });
    //如果存在下载中任务，每秒刷新一次
    if (tasks.where((task) => task.status == DownloadTaskStatus.running || task.status == DownloadTaskStatus.enqueued).length > 0) {
      if (timer == null) {
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          getData();
        });
      }
    } else {
      timer?.cancel();
    }
  }

  Future<bool> onWillPop() {
    // if (multiSelect) {
    //   setState(() {
    //     multiSelect = false;
    //     selectedFiles = [];
    //   });
    // } else {
    //   if (paths.length > 1) {
    //     paths.removeLast();
    //     String path = "";
    //
    //     if (paths.length == 1) {
    //       path = "/";
    //     } else {
    //       path = paths.join("/").substring(1);
    //     }
    //     goPath(path);
    //   } else {
    //     print("可以返回");
    //     return Future.value(true);
    //   }
    // }

    return Future.value(true);
  }

  Widget _buildDownloadStatus(DownloadTaskStatus status, int progress) {
    if (status == DownloadTaskStatus.complete) {
      return NeuCard(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        margin: EdgeInsets.only(bottom: 3),
        bevel: 0,
        decoration: NeumorphicDecoration(
          color: Colors.lightGreen,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "下载完成",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (status == DownloadTaskStatus.failed) {
      return NeuCard(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        margin: EdgeInsets.only(bottom: 3),
        bevel: 0,
        decoration: NeumorphicDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "下载失败",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (status == DownloadTaskStatus.canceled) {
      return NeuCard(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        margin: EdgeInsets.only(bottom: 3),
        bevel: 0,
        decoration: NeumorphicDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "取消下载",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (status == DownloadTaskStatus.paused) {
      return NeuCard(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        margin: EdgeInsets.only(bottom: 3),
        bevel: 0,
        decoration: NeumorphicDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "暂停下载",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (status == DownloadTaskStatus.running) {
      return NeuCard(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        margin: EdgeInsets.only(bottom: 3),
        bevel: 0,
        decoration: NeumorphicDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "$progress%",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (status == DownloadTaskStatus.enqueued) {
      return NeuCard(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        margin: EdgeInsets.only(bottom: 3),
        bevel: 0,
        decoration: NeumorphicDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "等待下载",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildTaskItem(DownloadTask task) {
    FileType fileType = Util.fileType(task.filename);
    // String path = file['path'];
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20, right: 20),
      child: NeuButton(
        onPressed: () async {
          if (fileType == FileType.image) {
            //获取当前目录全部图片文件
            List<String> images = [];
            int index = 0;
            for (int i = 0; i < tasks.length; i++) {
              if (task.status == DownloadTaskStatus.complete && Util.fileType(task.filename) == FileType.image) {
                images.add(tasks[i].savedDir + "/" + tasks[i].filename);
                if (tasks[i] == task) {
                  index = images.length - 1;
                }
              }
            }
            Navigator.of(context).push(TransparentMaterialPageRoute(
                builder: (context) {
                  return PreviewPage(
                    images,
                    index,
                    network: false,
                  );
                },
                settings: RouteSettings(name: "preview_image")));
          } else {
            var result = await FlutterDownloader.open(taskId: task.taskId);
            if (!result) {
              Util.toast("不支持打开此文件");
            }
          }
        },
        // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 8,
        child: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Hero(
              tag: task.savedDir + "/" + task.filename,
              child: FileIcon(
                fileType,
                thumb: task.status == DownloadTaskStatus.complete ? task.savedDir + "/" + task.filename : null,
                network: false,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.filename,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    DateTime.fromMillisecondsSinceEpoch(task.timeCreated).format("Y/m/d H:i:s"),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _buildDownloadStatus(task.status, task.progress),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: NeuButton(
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Material(
                        color: Colors.transparent,
                        child: NeuCard(
                          width: double.infinity,
                          padding: EdgeInsets.all(22),
                          bevel: 5,
                          curveType: CurveType.emboss,
                          decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "选择操作",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 22,
                              ),
                              NeuButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: true);
                                  await getData();
                                },
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                bevel: 5,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "删除",
                                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              NeuButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                bevel: 5,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "取消",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                padding: EdgeInsets.only(left: 5, right: 3, top: 4, bottom: 4),
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 2,
                child: Icon(
                  CupertinoIcons.right_chevron,
                  size: 18,
                ),
              ),
            ),
            SizedBox(
              width: 20,
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
        title: Text(
          "下载",
        ),
        actions: [
          if (Platform.isAndroid)
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
                        return DownloadSetting();
                      },
                      settings: RouteSettings(name: "download_setting"),
                    ),
                  );
                },
                child: Image.asset(
                  "assets/icons/setting.png",
                  width: 20,
                  height: 20,
                ),
              ),
            ),
        ],
      ),
      body: loading
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : tasks.length > 0
              ? ListView(
                  children: tasks.reversed.map(_buildTaskItem).toList(),
                )
              : Center(
                  child: Text("暂无下载任务"),
                ),
    );
  }
}
