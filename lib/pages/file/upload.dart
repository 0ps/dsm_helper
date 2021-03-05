import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dsm_helper/pages/file/select_folder.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Upload extends StatefulWidget {
  final String path;
  final List<String> selectedFilesPath;
  Upload(this.path, {this.selectedFilesPath});
  @override
  _UploadState createState() => _UploadState();
}

class UploadItem {
  String path;
  String name;
  int fileSize;
  int uploadSize;
  UploadStatus status;
  CancelToken cancelToken;
  UploadItem(this.path, this.name, {this.fileSize = 0, this.uploadSize = 0, this.status = UploadStatus.wait}) {
    cancelToken = CancelToken();
  }
}

class _UploadState extends State<Upload> {
  String savePath = "";
  List<UploadItem> uploads = [];
  @override
  void initState() {
    setState(() {
      savePath = widget.path ?? "";
    });
    if (widget.selectedFilesPath != null) {
      uploads = widget.selectedFilesPath.map((filePath) {
        File file = File(filePath);
        return UploadItem(
          filePath,
          filePath.split("/").last,
          fileSize: file.lengthSync(),
        );
      }).toList();
      setState(() {});
    }
    super.initState();
  }

  Widget _buildUploadStatus(UploadItem upload) {
    if (upload.status == UploadStatus.complete) {
      return Label(
        "上传完成",
        Colors.lightGreen,
        fill: true,
        fontSize: 10,
        height: 22,
      );
    } else if (upload.status == UploadStatus.failed) {
      return Label(
        "上传失败",
        Colors.redAccent,
        fill: true,
        fontSize: 10,
        height: 22,
      );
    } else if (upload.status == UploadStatus.canceled) {
      return Label(
        "取消上传",
        Colors.redAccent,
        fill: true,
        fontSize: 10,
        height: 22,
      );
    } else if (upload.status == UploadStatus.running) {
      return Label(
        "${(upload.uploadSize / (upload.fileSize == 0 ? 1 : upload.fileSize) * 100).toStringAsFixed(2)}%",
        Colors.lightBlueAccent,
        fill: true,
        fontSize: 10,
        height: 22,
      );
    } else if (upload.status == UploadStatus.wait) {
      return Label(
        "等待上传",
        Colors.lightBlueAccent,
        fill: true,
        fontSize: 10,
        height: 22,
      );
    } else {
      return Container();
    }
  }

  Widget _buildUploadItem(UploadItem upload) {
    FileType fileType = Util.fileType(upload.path);
    // String path = file['path'];
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20, right: 20),
      child: NeuButton(
        onPressed: () async {},
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
              tag: upload.path,
              child: FileIcon(
                fileType,
                thumb: upload.path,
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
                    upload.name,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _buildUploadStatus(upload),
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
                                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                              if (upload.status == UploadStatus.failed) ...[
                                SizedBox(
                                  height: 22,
                                ),
                                NeuButton(
                                  onPressed: () async {
                                    setState(() {
                                      upload.status = UploadStatus.wait;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  bevel: 5,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "重试",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                              SizedBox(
                                height: 22,
                              ),
                              NeuButton(
                                onPressed: () async {
                                  setState(() {
                                    uploads.remove(upload);
                                  });
                                  Navigator.of(context).pop();
                                },
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                bevel: 5,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "取消上传",
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
                  color: Color(0xfff0f0f0),
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
        leading: AppBackButton(context),
        title: Text(
          "文件上传",
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: NeuButton(
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
                      savePath = res[0];
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
                        "上传位置",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        savePath == "" ? "请选择上传位置" : savePath,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: uploads.length > 0
                ? ListView.builder(
                    itemBuilder: (context, i) {
                      return _buildUploadItem(uploads[i]);
                    },
                    itemCount: uploads.length,
                  )
                : Center(
                    child: Text("暂无待上传文件"),
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
                                    "选择添加方式",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      final List<AssetEntity> assets = await AssetPicker.pickAssets(context);
                                      if (assets != null && assets.length > 0) {
                                        assets.forEach((asset) {
                                          asset.file.then((file) {
                                            setState(() {
                                              uploads.add(UploadItem(file.path, file.path.split("/").last));
                                            });
                                          });
                                        });
                                      } else {
                                        print("未选择文件");
                                      }
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "上传图片",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: true);

                                      if (result != null) {
                                        setState(() {
                                          uploads.addAll(result.files.map((file) {
                                            return UploadItem(file.path, file.name, fileSize: file.size);
                                          }).toList());
                                        });
                                      } else {
                                        // User canceled the picker
                                      }
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "上传文件",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
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
                    child: Text("添加文件"),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: NeuButton(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () async {
                      if (savePath.isBlank) {
                        Util.vibrate(FeedbackType.warning);
                        Util.toast("请选择上传位置");
                        return;
                      }
                      final RegExp _asciiOnly = RegExp(r'^[\x00-\x7F]+$');
                      print(_asciiOnly.hasMatch(savePath));
                      // return;
                      for (int i = 0; i < uploads.length; i++) {
                        UploadItem upload = uploads[i];
                        if (upload.status != UploadStatus.wait) {
                          continue;
                        }
                        //上传文件
                        setState(() {
                          upload.status = UploadStatus.running;
                        });

                        var res = await Api.upload(savePath, upload.path, upload.cancelToken, (progress, total) {
                          setState(() {
                            upload.uploadSize = progress;
                            upload.fileSize = total;
                          });
                        });
                        print(res);
                        if (res['success']) {
                          setState(() {
                            upload.status = UploadStatus.complete;
                          });
                        } else {
                          setState(() {
                            upload.status = UploadStatus.failed;
                          });
                        }
                      }
                    },
                    child: Text("开始上传"),
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
