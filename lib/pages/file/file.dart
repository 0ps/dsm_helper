import 'package:android_intent/android_intent.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_station/pages/common/preview.dart';
import 'package:file_station/util/function.dart';
import 'package:file_station/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';

class Files extends StatefulWidget {
  @override
  _FilesState createState() => _FilesState();
}

class _FilesState extends State<Files> {
  List paths = ["/"];
  List files = [];
  bool loading = true;
  bool success = true;
  String msg = "";
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    getShareList();
    super.initState();
  }

  setPaths(String path) {
    if (path == "/") {
      setState(() {
        paths = ["/"];
      });
    } else {
      List<String> items = path.split("/");
      items[0] = "/";
      setState(() {
        paths = items;
      });
    }
  }

  getShareList() async {
    setState(() {
      loading = true;
    });
    var res = await Api.shareList();
    setState(() {
      loading = false;
      success = res['success'];
    });
    if (res['success']) {
      setState(() {
        files = res['data']['shares'];
      });
    } else {
      setState(() {
        msg = res['msg'] ?? "加载失败，code:${res['error']['code']}";
      });
    }
  }

  getFileList(String path) async {
    setState(() {
      loading = true;
    });
    var res = await Api.fileList(path);
    setState(() {
      loading = false;
      success = res['success'];
    });
    if (res['success']) {
      setState(() {
        files = res['data']['files'];
      });
    } else {
      setState(() {
        msg = res['msg'] ?? "加载失败，code:${res['error']['code']}";
      });
    }
  }

  goPath(String path) async {
    setPaths(path);
    if (path == "/") {
      await getShareList();
    } else {
      await getFileList(path);
    }
    double offset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(offset, duration: Duration(milliseconds: 200), curve: Curves.ease);
  }

  Widget _buildFileItem(file) {
    FileType fileType = Util.fileType(file['name']);
    String path = file['path'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      child: NeuButton(
        onPressed: () async {
          if (file['isdir']) {
            goPath(file['path']);
          } else if (fileType == FileType.image) {
            //获取当前目录全部图片文件
            List<String> images = [];
            int index = 0;
            for (int i = 0; i < files.length; i++) {
              if (Util.fileType(files[i]['name']) == FileType.image) {
                // print(files[i]['name']);
                images.add(Util.baseUrl + "/webapi/entry.cgi?path=${files[i]['path']}&size=original&api=SYNO.FileStation.Thumb&method=get&version=2&_sid=${Util.sid}&animate=true");
                if (files[i]['name'] == file['name']) {
                  index = images.length - 1;
                }
              }
            }
            print(images);
            Navigator.of(context).push(TransparentMaterialPageRoute(builder: (context) {
              return PreviewPage(images, index);
            }));
          } else if (fileType == FileType.movie) {
            AndroidIntent intent = AndroidIntent(
              action: 'action_view',
              data: Util.baseUrl + "/webapi/entry.cgi?api=SYNO.FileStation.Download&version=1&method=download&path=${file['path']}&mode=open&_sid=${Util.sid}",
              arguments: {},
              type: "video/*",
            );
            await intent.launch();
            // launch(Util.baseUrl + "/webapi/FileStation/file_download.cgi?api=SYNO.FileStation.Download&version=1&method=download&path=${file['path']}&mode=open", forceSafariVC: false, forceWebView: false);
          } else {
            print(file['name']);
          }
        },
        // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Hero(
              tag: Util.baseUrl + "/webapi/entry.cgi?path=$path&size=original&api=SYNO.FileStation.Thumb&method=get&version=2&_sid=${Util.sid}&animate=true",
              child: FileIcon(
                file['isdir'] ? FileType.folder : fileType,
                thumb: file['path'],
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
                    file['name'],
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    DateTime.fromMillisecondsSinceEpoch(file['additional']['time']['crtime'] * 1000).format("Y-m-d H:i:s"),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            NeuCard(
              padding: EdgeInsets.only(left: 5, right: 3, top: 4, bottom: 4),
              decoration: NeumorphicDecoration(
                color: Color(0xfff0f0f0),
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 2,
              child: Icon(CupertinoIcons.right_chevron),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathItem(BuildContext context, int index) {
    return Container(
      margin: index == 0 ? EdgeInsets.only(left: 20) : null,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: NeuButton(
        onPressed: () {
          String path = "";
          List<String> items = [];
          if (index == 0) {
            path = "/";
          } else {
            items = paths.getRange(1, index + 1).toList();
            path = "/" + items.join("/");
          }
          goPath(path);
        },
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 5,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: index == 0
            ? Icon(
                CupertinoIcons.home,
                size: 16,
              )
            : Text(
                paths[index],
                style: TextStyle(fontSize: 12),
              ),
      ),
    );
  }

  Future<bool> onWillPop() {
    print("back");
    print(paths.length);
    if (paths.length > 1) {
      paths.removeLast();
      String path = "";

      if (paths.length == 1) {
        path = "/";
      } else {
        path = "/" + paths.getRange(1, paths.length).join("/");
      }
      print(path);
      goPath(path);
    }
    return new Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "文件",
            style: Theme.of(context).textTheme.headline6,
          ),
          brightness: Brightness.light,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              height: 45,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: ListView.separated(
                controller: _scrollController,
                itemBuilder: _buildPathItem,
                itemCount: paths.length,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, i) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Icon(
                      CupertinoIcons.right_chevron,
                      size: 14,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: loading
                  ? Center(
                      child: NeuCard(
                        padding: EdgeInsets.all(50),
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CupertinoActivityIndicator(
                          radius: 14,
                        ),
                      ),
                    )
                  : success
                      ? ListView.builder(
                          itemBuilder: (context, i) {
                            return _buildFileItem(files[i]);
                          },
                          itemCount: files.length,
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("$msg"),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: 200,
                                child: NeuButton(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  onPressed: () {
                                    String path = paths.join("/").substring(1);
                                    goPath(path);
                                  },
                                  child: Text(
                                    ' 刷新 ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
