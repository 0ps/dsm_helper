import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dsm_helper/pages/common/select_ablum.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:vibrate/vibrate.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../file/select_folder.dart';
import 'package:neumorphic/neumorphic.dart';

class Backup extends StatefulWidget {
  @override
  _BackupState createState() => _BackupState();
}

enum UploadFileType { picture, video }

class UploadItem {
  File file;
  int fileSize;
  int uploadSize;
  UploadStatus status;
  UploadFileType type;
  DateTime modifyTime;

  CancelToken cancelToken;
  UploadItem(this.file, this.type, this.modifyTime, {this.fileSize = 0, this.uploadSize = 0, this.status = UploadStatus.wait}) {
    cancelToken = CancelToken();
  }

  @override
  String toString() {
    return 'UploadItem{modifyTime: $modifyTime}';
  }
}

class _BackupState extends State<Backup> {
  List<UploadItem> uploads = [];
  List<AssetPathEntity> albums = [];
  String backupFolder = "";
  DateTime lastBackupTime = DateTime.now().add(Duration(days: -5));
  UploadItem uploading;
  bool cancel = false;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    String last = await Util.getStorage("last_backup_time");

    lastBackupTime = last.isNotBlank ? DateTime.fromMillisecondsSinceEpoch(int.parse(last)) : null;
    backupFolder = await Util.getStorage("backup_folder") ?? "";
    setState(() {});
    String backupAlbumStr = await Util.getStorage("backup_album");
    List backupAlbums = [];
    if (await PhotoManager.requestPermission()) {
      if (backupAlbumStr.isNotBlank) {
        backupAlbums = json.decode(backupAlbumStr);

        List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
        list.forEach((album) {
          if (backupAlbums.contains(album.id)) {
            albums.add(album);
          }
        });
        setState(() {});
      }
    } else {
      Util.vibrate(FeedbackType.warning);
      Util.toast("请先允许群晖助手访问相册");
    }

    getAssetCount();
    // if (Platform.isAndroid) {
    //   String last = await Util.getStorage("last_backup_time");
    //
    //   lastBackupTime = last.isNotBlank ? DateTime.fromMillisecondsSinceEpoch(int.parse(last)) : null;
    //   backupFolder = await Util.getStorage("backup_folder") ?? "";
    //   setState(() {});
    //   Directory directory = Directory(backupSource);
    //   List<FileSystemEntity> list = directory.listSync();
    //   // print(await list.length);
    //
    //   list.forEach((element) {
    //     if (!element.path.split("/").last.startsWith(".")) {
    //       Directory(element.path).list(recursive: true).listen((event) {
    //         if (event is File) {
    //           String ext = event.path.split("/").last.split(".").last;
    //           if (!["back", "tmp"].contains(ext)) {
    //             DateTime lastModify = event.lastModifiedSync();
    //             setState(() {
    //               if (lastBackupTime != null) {
    //                 if (lastModify.isAfter(lastBackupTime)) {
    //                   uploads.add(UploadItem(event, ext == "mp4" ? UploadFileType.video : UploadFileType.picture, lastModify, fileSize: event.lengthSync()));
    //                 }
    //               } else {
    //                 uploads.add(UploadItem(event, ext == "mp4" ? UploadFileType.video : UploadFileType.picture, lastModify, fileSize: event.lengthSync()));
    //               }
    //             });
    //           }
    //         }
    //       });
    //     }
    //   });
    // } else {
    //
    // }
  }

  getAssetCount() async {
    uploads = [];
    albums.forEach((path) async {
      List<AssetEntity> assetList = await path.assetList;
      assetList.forEach((asset) async {
        uploads.add(UploadItem(await asset.originFile, asset.type == AssetType.video ? UploadFileType.video : UploadFileType.picture, asset.createDateTime));
        setState(() {});
      });
    });
  }

  Widget _buildAlbumLabel(AssetPathEntity album) {
    return Label(
      "${album.name} (${album.assetCount})",
      Colors.lightBlueAccent,
      fill: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("相册备份"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          if (uploading != null) ...[
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              curveType: CurveType.flat,
              child: Stack(
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width - 40) * (uploading.uploadSize / (uploading.fileSize == 0 ? 1 : uploading.fileSize)),
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        uploading.type == UploadFileType.picture
                            ? Image.file(
                                uploading.file,
                                height: 40,
                                width: 40,
                              )
                            : FileIcon(FileType.movie),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                uploading.file.path.split("/").last,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(fontSize: 13),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                uploading.file.parent.path,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
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
                    backupFolder = res[0];
                    Util.setStorage("backup_folder", backupFolder);
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
                      "备份目的地",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      backupFolder == "" ? "请选择目的地" : backupFolder,
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
          NeuButton(
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return SelectAlbum(
                    multi: true,
                    selected: albums,
                  );
                },
              ).then((res) {
                if (res != null) {
                  setState(() {
                    albums = res;
                  });
                  List backupAlbums = albums.map((e) => e.id).toList();
                  Util.setStorage("backup_album", json.encode(backupAlbums));

                  getAssetCount();
                }
              });
            },
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "备份源",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    albums.length > 0
                        ? Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: albums.map(_buildAlbumLabel).toList(),
                          )
                        : Text(
                            "未选择备份源",
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
            padding: EdgeInsets.all(12),
            curveType: CurveType.flat,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "继续备份",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      lastBackupTime != null ? lastBackupTime.format("Y-m-d H:i:s") : "从未备份过",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      "${uploads.where((upload) => upload.status != UploadStatus.complete && upload.type == UploadFileType.picture).length}张照片 ${uploads.where((upload) => upload.status != UploadStatus.complete && upload.type == UploadFileType.video).length}个视频待备份",
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
            padding: EdgeInsets.all(12),
            curveType: CurveType.flat,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "全新备份",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "${uploads.where((upload) => upload.status != UploadStatus.complete && upload.type == UploadFileType.picture).length}张照片 ${uploads.where((upload) => upload.status != UploadStatus.complete && upload.type == UploadFileType.video).length}个视频待备份",
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
          GestureDetector(
            onTap: () {
              Util.toast("暂不支持自动备份");
            },
            child: NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              curveType: CurveType.flat,
              bevel: 12,
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Text("自动备份"),
                  Spacer(),
                  // Icon(
                  //   CupertinoIcons.checkmark_alt,
                  //   color: Color(0xffff9813),
                  // ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          uploading == null
              ? NeuButton(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () async {
                    if (backupFolder.isBlank) {
                      Util.vibrate(FeedbackType.warning);
                      Util.toast("请选择备份目的地");
                      return;
                    }
                    if (albums.length == 0) {
                      Util.vibrate(FeedbackType.warning);
                      Util.toast("请选择备份源");
                      return;
                    }
                    //对待备份文件进行排序
                    uploads.sort((a, b) {
                      return a.modifyTime.isAtSameMomentAs(b.modifyTime)
                          ? 0
                          : a.modifyTime.isBefore(b.modifyTime)
                              ? -1
                              : 1;
                    });
                    for (int i = 0; i < uploads.length; i++) {
                      if (cancel) {
                        cancel = false;
                        setState(() {
                          lastBackupTime = uploading.modifyTime;
                        });
                        uploading = null;
                        Util.toast("备份任务已暂停");
                        break;
                      }
                      setState(() {
                        uploading = uploads[i];
                      });
                      if (uploading.status != UploadStatus.wait) {
                        continue;
                      }
                      //上传文件
                      setState(() {
                        uploading.status = UploadStatus.running;
                      });
                      var res = await Api.upload(backupFolder, uploading.file.path, uploading.cancelToken, (progress, total) {
                        // print("$progress,$total");
                        setState(() {
                          uploading.uploadSize = progress;
                          uploading.fileSize = total;
                        });
                      });
                      if (res['success']) {
                        print(uploading.modifyTime);
                        print(uploading.modifyTime.millisecond);
                        Util.setStorage("last_backup_time", uploading.modifyTime.millisecondsSinceEpoch.toString());
                        setState(() {
                          uploading.status = UploadStatus.complete;
                        });
                      } else {
                        setState(() {
                          uploading.status = UploadStatus.failed;
                        });
                      }
                      if (i == uploads.length - 1) {
                        setState(() {
                          uploading = null;
                          lastBackupTime = DateTime.now();
                        });
                      }
                    }
                  },
                  child: Text("开始备份"),
                )
              : NeuButton(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () async {
                    cancel = true;
                    Util.toast("当前文件上传完成后将暂停任务");
                  },
                  child: Text("暂停备份"),
                ),
        ],
      ),
    );
  }
}
