import 'package:dio/dio.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Upload extends StatefulWidget {
  final String path;
  Upload(this.path);
  @override
  _UploadState createState() => _UploadState();
}

enum UploadStatus {
  running,
  complete,
  failed,
  canceled,
  wait,
}

class UploadItem {
  PlatformFile file;
  int fileSize;
  int uploadSize;
  UploadStatus status;
  CancelToken cancelToken;
  UploadItem(this.file, {this.fileSize = 0, this.uploadSize = 0, this.status = UploadStatus.wait}) {
    cancelToken = CancelToken();
  }
}

class _UploadState extends State<Upload> {
  List<UploadItem> uploads = [];
  @override
  void initState() {
    super.initState();
  }

  Widget _buildUploadStatus(UploadItem upload) {
    if (upload.status == UploadStatus.complete) {
      return NeuCard(
        padding: EdgeInsets.symmetric(vertical: 2),
        bevel: 0,
        width: 60,
        height: 20,
        alignment: Alignment.center,
        decoration: NeumorphicDecoration(
          color: Colors.lightGreen,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "上传完成",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (upload.status == UploadStatus.failed) {
      return NeuCard(
        padding: EdgeInsets.symmetric(vertical: 2),
        bevel: 0,
        width: 60,
        height: 20,
        decoration: NeumorphicDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "上传失败",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (upload.status == UploadStatus.canceled) {
      return NeuCard(
        padding: EdgeInsets.symmetric(vertical: 2),
        bevel: 0,
        width: 60,
        height: 20,
        alignment: Alignment.center,
        decoration: NeumorphicDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "取消上传",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (upload.status == UploadStatus.running) {
      return NeuCard(
        padding: EdgeInsets.symmetric(vertical: 4),
        bevel: 0,
        width: 60,
        height: 20,
        alignment: Alignment.center,
        decoration: NeumorphicDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "${(upload.uploadSize / (upload.fileSize == 0 ? 1 : upload.fileSize) * 100).toStringAsFixed(2)}%",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else if (upload.status == UploadStatus.wait) {
      return NeuCard(
        padding: EdgeInsets.symmetric(vertical: 2),
        bevel: 0,
        width: 60,
        height: 20,
        alignment: Alignment.center,
        decoration: NeumorphicDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "等待上传",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildUploadItem(UploadItem upload) {
    print(upload.file.path);
    FileType fileType = Util.fileType(upload.file.name);
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
              tag: upload.file.path,
              child: FileIcon(
                fileType,
                thumb: upload.file.path,
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
                    upload.file.name,
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
        title: Text(
          "文件上传",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, i) {
                return _buildUploadItem(uploads[i]);
              },
              itemCount: uploads.length,
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
                      FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: true);

                      if (result != null) {
                        setState(() {
                          uploads.addAll(result.files.map((file) {
                            return UploadItem(file);
                          }).toList());
                        });
                      } else {
                        // User canceled the picker
                      }
                    },
                    child: Text("选择文件"),
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
                      for (int i = 0; i < uploads.length; i++) {
                        UploadItem upload = uploads[i];
                        if (upload.status != UploadStatus.wait) {
                          continue;
                        }
                        //上传文件
                        setState(() {
                          upload.status = UploadStatus.running;
                        });
                        var res = await Api.upload(widget.path, upload.file.path, upload.cancelToken, (progress, total) {
                          // print("$progress,$total");
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
