import 'dart:async';

import 'package:android_intent/android_intent.dart';
import 'package:dsm_helper/pages/file/search.dart';
import 'package:dsm_helper/pages/file/select_folder.dart';
import 'package:dsm_helper/pages/file/share.dart';
import 'package:dsm_helper/pages/file/share_manager.dart';
import 'package:dsm_helper/pages/file/upload.dart';
import 'package:extended_image/extended_image.dart';
import 'package:dsm_helper/pages/common/preview.dart';
// import 'package:dsm_helper/pages/editor/editor.dart';
import 'package:dsm_helper/pages/file/detail.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

enum ListType { list, icon }

class Files extends StatefulWidget {
  Files({key}) : super(key: key);
  @override
  FilesState createState({key}) => FilesState();
}

class FilesState extends State<Files> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List paths = ["/"];
  List files = [];
  bool loading = true;
  bool favoriteLoading = true;
  List favorites = [];
  bool success = true;
  String msg = "";
  bool multiSelect = false;
  List<String> selectedFiles = [];
  ScrollController _pathScrollController = ScrollController();
  ScrollController _fileScrollController = ScrollController();
  Map processing = {};
  String sortBy = "name";
  String sortDirection = "ASC";
  bool searchResult = false;
  bool searching = false;
  Timer timer;
  ListType listType = ListType.list;
  Map scrollPosition = {};
  @override
  void initState() {
    getShareList();
    _fileScrollController.addListener(() {
      String path = "";
      if (paths.length > 1) {
        path = paths.join("/").substring(1);
      } else {
        path = "/";
      }
      print("$path --- ${_fileScrollController.offset}");
      scrollPosition[path] = _fileScrollController.offset;
      print(scrollPosition);
    });
    super.initState();
  }

  refresh() {
    String path = paths.join("/").substring(1);
    goPath(path);
  }

  bool get isDrawerOpen {
    return _scaffoldKey.currentState.isDrawerOpen;
  }

  closeDrawer() {
    if (_scaffoldKey.currentState.isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }

  setPaths(String path) {
    setState(() {
      searchResult = false;
      searching = false;
    });
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

  search(List<String> folders, String pattern, bool searchContent) async {
    setState(() {
      searchResult = true;
      searching = true;
      loading = true;
    });
    var res = await Api.searchTask(folders, pattern, searchContent: searchContent);
    if (res['success']) {
      bool r = await result(res['data']['taskid']);
      if (r != null && r == false) {
        //搜索未结束
        timer = Timer.periodic(Duration(seconds: 2), (timer) {
          result(res['data']['taskid']);
        });
      }
    }
  }

  Future<bool> result(String taskId) async {
    var res = await Api.searchResult(taskId);
    if (res['success']) {
      if (res['data']['finished']) {
        timer?.cancel();
      }
      setState(() {
        loading = false;
        searching = !res['data']['finished'];

        if (res['data']['files'] != null) {
          files = res['data']['files'];
        } else {
          files = [];
        }
      });

      return res['data']['finished'];
    } else {
      return null;
    }
  }

  getShareList() async {
    String listTypeStr = await Util.getStorage("file_list_type");

    setState(() {
      if (listTypeStr.isNotBlank) {
        if (listTypeStr == "list") {
          listType = ListType.list;
        } else {
          listType = ListType.icon;
        }
      } else {
        listType = ListType.list;
      }
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
      if (loading) {
        setState(() {
          msg = res['msg'] ?? "加载失败，code:${res['error']['code']}";
        });
      }
    }
  }

  getFileList(String path) async {
    setState(() {
      loading = true;
    });
    var res = await Api.fileList(path, sortBy: sortBy, sortDirection: sortDirection);
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
    setState(() {
      success = true;
    });
    setPaths(path);
    if (path == "/") {
      await getShareList();
    } else {
      await getFileList(path);
    }
    double offset = _pathScrollController.position.maxScrollExtent;
    await _pathScrollController.animateTo(offset, duration: Duration(milliseconds: 200), curve: Curves.ease);
    print(scrollPosition[path] ?? 0);
    _fileScrollController.jumpTo(scrollPosition[path] ?? 0);
  }

  Widget _buildSortMenu(BuildContext context, StateSetter setState) {
    return Material(
      color: Colors.transparent,
      child: NeuCard(
        width: double.infinity,
        bevel: 5,
        curveType: CurveType.emboss,
        decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              NeuCard(
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "name";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("名称"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "name" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "name"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "size";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("大小"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "size" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "size"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "type";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("文件类型"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "type" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "type"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "mtime";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("修改日期"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "mtime" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "mtime"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "crtime";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("创建日期"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "crtime" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "crtime"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "atime";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("最近访问时间"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "atime" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "atime"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "posix";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("权限"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "posix" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "posix"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "user";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("拥有者"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "user" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "user"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortBy = "group";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("群组"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortBy == "group" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortBy == "group"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              NeuCard(
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortDirection = "ASC";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("由小至大"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortDirection == "ASC" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortDirection == "ASC"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortDirection = "DESC";
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("由大至小"),
                            ),
                            NeuCard(
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              curveType: sortDirection == "DESC" ? CurveType.emboss : CurveType.flat,
                              padding: EdgeInsets.all(5),
                              bevel: 5,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: sortDirection == "DESC"
                                    ? Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 22,
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
                  "确定",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  deleteFile(List<String> file) {
    Util.vibrate(FeedbackType.warning);
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
                  "确认删除",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "确认要删除文件？",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 22,
                ),
                Row(
                  children: [
                    Expanded(
                      child: NeuButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          var res = await Api.deleteTask(file);
                          if (res['success']) {
                            //获取删除进度
                            timer = Timer.periodic(Duration(seconds: 1), (_) async {
                              //获取删除进度
                              try {
                                var result = await Api.deleteResult(res['data']['taskid']);
                                if (result['success'] != null && result['success']) {
                                  if (result['data']['finished']) {
                                    Util.toast("文件删除完成");
                                    timer.cancel();
                                    timer = null;
                                    setState(() {
                                      selectedFiles = [];
                                      multiSelect = false;
                                    });
                                    refresh();
                                  }
                                }
                              } catch (e) {
                                Util.toast("文件删除出错");
                                timer.cancel();
                                timer = null;
                              }
                            });
                          }
                        },
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        bevel: 5,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "确认删除",
                          style: TextStyle(fontSize: 18, color: Colors.redAccent),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: NeuButton(
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
                    ),
                  ],
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
  }

  compressFile(List<String> file) {
    String zipName = "";
    String destPath = "";
    if (file.length == 1) {
      zipName = file[0].split("/").last + ".zip";
    } else {
      zipName = paths.last + ".zip";
    }
    destPath = paths.join("/").substring(1) + "/" + zipName;
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
                  "压缩文件",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "确认要压缩到$zipName？",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 22,
                ),
                NeuButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    var res = await Api.compressTask(file, destPath);
                    if (res['success']) {
                      //获取删除进度
                      timer = Timer.periodic(Duration(seconds: 1), (_) async {
                        //获取删除进度
                        try {
                          var result = await Api.compressResult(res['data']['taskid']);
                          if (result['success'] != null && result['success']) {
                            if (result['data']['finished']) {
                              Util.toast("文件压缩完成");
                              timer.cancel();
                              timer = null;
                              setState(() {
                                selectedFiles = [];
                                multiSelect = false;
                              });
                              refresh();
                            }
                          }
                        } catch (e) {
                          Util.toast("文件压缩出错");
                          timer.cancel();
                          timer = null;
                        }
                      });
                    }
                  },
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  bevel: 5,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "开始压缩",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                NeuButton(
                  onPressed: () async {
                    // Navigator.of(context).pop();
                    Util.toast("敬请期待");
                  },
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  bevel: 5,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "更多选项",
                    style: TextStyle(fontSize: 18),
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
  }

  Widget _buildFileItem(file) {
    FileType fileType = Util.fileType(file['name']);
    String path = file['path'];
    Widget actionButton = multiSelect
        ? NeuCard(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            curveType: selectedFiles.contains(file['path']) ? CurveType.emboss : CurveType.flat,
            padding: EdgeInsets.all(5),
            bevel: 5,
            child: SizedBox(
              width: 20,
              height: 20,
              child: selectedFiles.contains(file['path'])
                  ? Icon(
                      CupertinoIcons.checkmark_alt,
                      color: Color(0xffff9813),
                    )
                  : null,
            ),
          )
        : GestureDetector(
            onTap: () {
              Util.vibrate(FeedbackType.light);
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return Material(
                    color: Colors.transparent,
                    child: NeuCard(
                      width: double.infinity,
                      bevel: 5,
                      curveType: CurveType.emboss,
                      decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "选择操作",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              runSpacing: 20,
                              spacing: 20,
                              children: [
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 100) / 4,
                                  child: NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(CupertinoPageRoute(
                                          builder: (context) {
                                            return FileDetail(file);
                                          },
                                          settings: RouteSettings(name: "file_detail")));
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 20,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/icons/info_liner.png",
                                          width: 30,
                                        ),
                                        Text(
                                          "详情",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 100) / 4,
                                  child: NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      String url = Util.baseUrl + "/webapi/entry.cgi?api=SYNO.FileStation.Download&version=2&method=download&path=${Uri.encodeComponent(file['path'])}&mode=download&_sid=${Util.sid}";
                                      String filename = "";
                                      if (file['isdir']) {
                                        filename = file['name'] + ".zip";
                                      } else {
                                        filename = file['name'];
                                      }
                                      await Util.download(filename, url);
                                      Util.toast("已添加下载任务，请至下载页面查看");
                                      Util.downloadKey.currentState.getData();
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 20,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/icons/download.png",
                                          width: 30,
                                        ),
                                        Text(
                                          "下载",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (Util.fileType(file['name']) == FileType.zip)
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width - 100) / 4,
                                    child: NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        var res = await Api.extractTask(file['path'], paths.join("/").substring(1));
                                        if (res['success']) {
                                          //获取解压进度
                                          timer = Timer.periodic(Duration(seconds: 1), (_) async {
                                            //获取加压进度
                                            var result = await Api.extractResult(res['data']['taskid']);
                                            if (result['success'] != null && result['success']) {
                                              setState(() {
                                                processing[res['data']['taskid']] = result['data'];
                                              });
                                              if (result['data']['finished']) {
                                                Util.toast("文件解压完成");
                                                timer.cancel();
                                                timer = null;

                                                refresh();
                                                Future.delayed(Duration(seconds: 5)).then((value) {
                                                  setState(() {
                                                    processing.remove(res['data']['taskid']);
                                                  });
                                                });
                                              }
                                            }
                                          });
                                        }
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 20,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/icons/unzip.png",
                                            width: 30,
                                          ),
                                          Text(
                                            "解压",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (paths.length > 1)
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width - 100) / 4,
                                    child: NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        compressFile([file['path']]);
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 20,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/icons/archive.png",
                                            width: 30,
                                          ),
                                          Text(
                                            "压缩",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 100) / 4,
                                  child: NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(CupertinoPageRoute(
                                          builder: (context) {
                                            return Share(paths: [file['path']]);
                                          },
                                          settings: RouteSettings(name: "share")));
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 20,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/icons/share.png",
                                          width: 30,
                                        ),
                                        Text(
                                          "共享",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (file['isdir']) ...[
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width - 100) / 4,
                                    child: NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(CupertinoPageRoute(
                                            builder: (context) {
                                              return Share(
                                                paths: [file['path']],
                                                fileRequest: true,
                                              );
                                            },
                                            settings: RouteSettings(name: "share")));
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 20,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/icons/upload.png",
                                            width: 30,
                                          ),
                                          Text(
                                            "文件请求",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 100) / 4,
                                  child: NeuButton(
                                    onPressed: () async {
                                      TextEditingController nameController = TextEditingController.fromValue(TextEditingValue(text: file['name']));
                                      Navigator.of(context).pop();
                                      String name = "";
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) {
                                          return Material(
                                            color: Colors.transparent,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                NeuCard(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.symmetric(horizontal: 50),
                                                  curveType: CurveType.emboss,
                                                  bevel: 20,
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(25),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "重命名",
                                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                                        ),
                                                        SizedBox(
                                                          height: 16,
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
                                                            onChanged: (v) => name = v,
                                                            controller: nameController,
                                                            decoration: InputDecoration(
                                                              border: InputBorder.none,
                                                              hintText: "请输入新的名称",
                                                              labelText: "文件名",
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 16,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: NeuButton(
                                                                onPressed: () async {
                                                                  if (name.trim() == "") {
                                                                    Util.toast("请输入新文件名");
                                                                    return;
                                                                  }
                                                                  Navigator.of(context).pop();
                                                                  var res = await Api.rename(file['path'], name);
                                                                  if (res['success']) {
                                                                    Util.toast("重命名成功");
                                                                    refresh();
                                                                  } else {
                                                                    if (res['error']['errors'] != null && res['error']['errors'].length > 0 && res['error']['errors'][0]['code'] == 414) {
                                                                      Util.toast("重命名失败：指定的名称已存在");
                                                                    } else {
                                                                      Util.toast("重命名失败");
                                                                    }
                                                                  }
                                                                },
                                                                decoration: NeumorphicDecoration(
                                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                bevel: 20,
                                                                padding: EdgeInsets.symmetric(vertical: 10),
                                                                child: Text(
                                                                  "确定",
                                                                  style: TextStyle(fontSize: 18),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 16,
                                                            ),
                                                            Expanded(
                                                              child: NeuButton(
                                                                onPressed: () async {
                                                                  Navigator.of(context).pop();
                                                                },
                                                                decoration: NeumorphicDecoration(
                                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                bevel: 20,
                                                                padding: EdgeInsets.symmetric(vertical: 10),
                                                                child: Text(
                                                                  "取消",
                                                                  style: TextStyle(fontSize: 18),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 20,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/icons/edit.png",
                                          width: 30,
                                        ),
                                        Text(
                                          "重命名",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 100) / 4,
                                  child: NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      var res = await Api.favoriteAdd("${file['name']} - ${paths[1]}", file['path']);
                                      if (res['success']) {
                                        Util.toast("收藏成功");
                                      } else {
                                        Util.toast("收藏失败，代码${res['error']['code']}");
                                      }
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 20,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/icons/collect.png",
                                          width: 30,
                                        ),
                                        Text(
                                          "添加收藏",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (paths.length > 1)
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width - 100) / 4,
                                    child: NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        deleteFile([file['path']]);
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      bevel: 20,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/icons/delete.png",
                                            width: 30,
                                          ),
                                          Text(
                                            "删除",
                                            style: TextStyle(fontSize: 12, color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
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
                              bevel: 20,
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
                    ),
                  );
                },
              );
            },
            child: NeuCard(
              // padding: EdgeInsets.zero,
              curveType: CurveType.flat,
              padding: EdgeInsets.only(left: 6, right: 4, top: 5, bottom: 5),
              decoration: NeumorphicDecoration(
                // color: Colors.red,
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              bevel: 10,
              child: Icon(
                CupertinoIcons.right_chevron,
                size: 18,
              ),
            ),
          );
    return Container(
      width: listType == ListType.icon ? (MediaQuery.of(context).size.width - 80) / 3 : double.infinity,
      padding: listType == ListType.icon ? EdgeInsets.zero : EdgeInsets.only(bottom: 20.0),
      child: NeuButton(
        onLongPress: () {
          if (paths.length > 1) {
            Util.vibrate(FeedbackType.light);
            setState(() {
              multiSelect = true;
              selectedFiles.add(file['path']);
            });
          } else {
            Util.vibrate(FeedbackType.warning);
          }
        },
        onPressed: () async {
          Util.vibrate(FeedbackType.light);
          if (multiSelect) {
            setState(() {
              if (selectedFiles.contains(file['path'])) {
                selectedFiles.remove(file['path']);
              } else {
                selectedFiles.add(file['path']);
              }
            });
          } else {
            if (file['isdir']) {
              goPath(file['path']);
            } else {
              switch (fileType) {
                case FileType.image:
                  //获取当前目录全部图片文件
                  List<String> images = [];
                  int index = 0;
                  for (int i = 0; i < files.length; i++) {
                    if (Util.fileType(files[i]['name']) == FileType.image) {
                      images.add(Util.baseUrl + "/webapi/entry.cgi?path=${Uri.encodeComponent(files[i]['path'])}&size=original&api=SYNO.FileStation.Thumb&method=get&version=2&_sid=${Util.sid}&animate=true");
                      if (files[i]['name'] == file['name']) {
                        index = images.length - 1;
                      }
                    }
                  }
                  Navigator.of(context).push(TransparentMaterialPageRoute(
                    builder: (context) {
                      return PreviewPage(images, index);
                    },
                    fullscreenDialog: true,
                  ));
                  break;
                case FileType.movie:
                  AndroidIntent intent = AndroidIntent(
                    action: 'action_view',
                    data: Util.baseUrl + "/webapi/entry.cgi?api=SYNO.FileStation.Download&version=1&method=download&path=${Uri.encodeComponent(file['path'])}&mode=open&_sid=${Util.sid}",
                    arguments: {},
                    type: "video/*",
                  );
                  await intent.launch();
                  break;
                case FileType.music:
                  AndroidIntent intent = AndroidIntent(
                    action: 'action_view',
                    data: Util.baseUrl + "/webapi/entry.cgi?api=SYNO.FileStation.Download&version=1&method=download&path=${Uri.encodeComponent(file['path'])}&mode=open&_sid=${Util.sid}",
                    arguments: {},
                    type: "audio/*",
                  );
                  await intent.launch();
                  break;
                case FileType.word:
                  AndroidIntent intent = AndroidIntent(
                    action: 'action_view',
                    data: Util.baseUrl + "/webapi/entry.cgi?api=SYNO.FileStation.Download&version=1&method=download&path=${Uri.encodeComponent(file['path'])}&mode=open&_sid=${Util.sid}",
                    arguments: {},
                    type: "application/msword|application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                  );
                  await intent.launch();
                  break;
                case FileType.excel:
                  AndroidIntent intent = AndroidIntent(
                    action: 'action_view',
                    data: Util.baseUrl + "/webapi/entry.cgi?api=SYNO.FileStation.Download&version=1&method=download&path=${Uri.encodeComponent(file['path'])}&mode=open&_sid=${Util.sid}",
                    arguments: {},
                    type: "application/vnd.ms-excel|application/x-excel|application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                  );
                  await intent.launch();
                  break;
                // case FileType.code:
                //   Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                //     return Editor();
                //   }));
                //   break;
                default:
                  Util.toast("暂不支持打开此类型文件");
              }
            }
          }
        },
        padding: EdgeInsets.zero,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 20,
        child: listType == ListType.list
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Hero(
                      tag: Util.baseUrl + "/webapi/entry.cgi?path=${Uri.encodeComponent(path)}&size=original&api=SYNO.FileStation.Thumb&method=get&version=2&_sid=${Util.sid}&animate=true",
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
                            (file['isdir'] ? "" : "${Util.formatSize(file['additional']['size'])}" + " | ") + DateTime.fromMillisecondsSinceEpoch(file['additional']['time']['crtime'] * 1000).format("Y/m/d H:i:s"),
                            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    actionButton,
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Hero(
                          tag: Util.baseUrl + "/webapi/entry.cgi?path=${Uri.encodeComponent(path)}&size=original&api=SYNO.FileStation.Thumb&method=get&version=2&_sid=${Util.sid}&animate=true",
                          child: FileIcon(
                            file['isdir'] ? FileType.folder : fileType,
                            thumb: file['path'],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          file['name'],
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // if (multiSelect)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: actionButton,
                    ),
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
    if (multiSelect) {
      setState(() {
        multiSelect = false;
        selectedFiles = [];
      });
    } else if (searchResult) {
      setState(() {
        refresh();
      });
    } else {
      if (paths.length > 1) {
        paths.removeLast();
        String path = "";

        if (paths.length == 1) {
          path = "/";
        } else {
          path = paths.join("/").substring(1);
        }
        goPath(path);
      } else {
        return Future.value(true);
      }
    }

    return Future.value(false);
  }

  Widget _buildProcessList() {
    List<Widget> children = [];
    processing.forEach((key, value) {
      children.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(value['path']),
                    flex: 1,
                  ),
                  Icon(Icons.arrow_right_alt_sharp),
                  Expanded(
                    child: Text(value['dest_folder_path']),
                    flex: 1,
                  ),
                  // Text(value['processing_path']),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              NeuCard(
                curveType: CurveType.flat,
                bevel: 10,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FAProgressBar(
                  backgroundColor: Colors.transparent,
                  changeColorValue: 100,
                  changeProgressColor: Colors.green,
                  progressColor: Colors.blue,
                  size: 20,
                  currentValue: (num.parse("${value['progress']}") * 100).toInt(),
                  displayText: '%',
                ),
              ),
            ],
          ),
        ),
      );
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildFavoriteItem(favorite) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: NeuButton(
        onPressed: () {
          if (favorite['status'] == "broken") {
            Util.toast("文件或目录不存在");
          } else {
            goPath(favorite['path']);
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              FileIcon(
                FileType.folder,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(child: Text(favorite['name'])),
              SizedBox(
                width: 10,
              ),
              NeuCard(
                // padding: EdgeInsets.zero,
                curveType: CurveType.flat,
                padding: EdgeInsets.only(left: 6, right: 4, top: 5, bottom: 5),
                decoration: NeumorphicDecoration(
                  // color: Colors.red,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                bevel: 10,
                child: Icon(
                  CupertinoIcons.right_chevron,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        padding: EdgeInsets.zero,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "文件",
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
          child: NeuButton(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            bevel: 5,
            onPressed: () async {
              if (multiSelect) {
                setState(() {
                  multiSelect = false;
                  selectedFiles = [];
                });
              } else {
                _scaffoldKey.currentState.openDrawer();
                setState(() {
                  favoriteLoading = true;
                });
                var res = await Api.favoriteList();
                setState(() {
                  favoriteLoading = false;
                });
                if (res['success']) {
                  setState(() {
                    favorites = res['data']['favorites'];
                  });
                }
              }
            },
            child: multiSelect
                ? Icon(Icons.close)
                : Image.asset(
                    "assets/icons/collect.png",
                    width: 20,
                  ),
          ),
        ),
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
                setState(() {
                  listType = listType == ListType.list ? ListType.icon : ListType.list;
                });
                Util.setStorage("file_list_type", listType == ListType.list ? "list" : "icon");
              },
              child: Image.asset(
                listType == ListType.list ? "assets/icons/list_list.png" : "assets/icons/list_icon.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
          if (multiSelect)
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
                  if (selectedFiles.length == files.length) {
                    selectedFiles = [];
                  } else {
                    selectedFiles = [];
                    files.forEach((file) {
                      selectedFiles.add(file['path']);
                    });
                  }

                  setState(() {});
                },
                child: Image.asset(
                  "assets/icons/select_all.png",
                  width: 20,
                  height: 20,
                ),
              ),
            )
          else if (paths.length > 1)
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
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: _buildSortMenu,
                      );
                    },
                  ).then((value) {
                    refresh();
                  });
                },
                child: Image.asset(
                  "assets/icons/sort.png",
                  width: 20,
                  height: 20,
                ),
              ),
            ),
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
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: Colors.transparent,
                      child: NeuCard(
                        width: double.infinity,
                        bevel: 20,
                        curveType: CurveType.emboss,
                        decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "选择操作",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Container(
                                width: double.infinity,
                                child: Wrap(
                                  runSpacing: 20,
                                  spacing: 20,
                                  children: [
                                    if (paths.length > 1) ...[
                                      SizedBox(
                                        width: (MediaQuery.of(context).size.width - 100) / 4,
                                        child: NeuButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            String name = "";
                                            showCupertinoDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Material(
                                                    color: Colors.transparent,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        NeuCard(
                                                          width: double.infinity,
                                                          margin: EdgeInsets.symmetric(horizontal: 50),
                                                          curveType: CurveType.emboss,
                                                          bevel: 20,
                                                          decoration: NeumorphicDecoration(
                                                            color: Theme.of(context).scaffoldBackgroundColor,
                                                            borderRadius: BorderRadius.circular(25),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(20),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  "新建文件夹",
                                                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                                                ),
                                                                SizedBox(
                                                                  height: 16,
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
                                                                    onChanged: (v) => name = v,
                                                                    decoration: InputDecoration(
                                                                      border: InputBorder.none,
                                                                      hintText: "请输入文件夹名",
                                                                      labelText: "文件夹名",
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: NeuButton(
                                                                        onPressed: () async {
                                                                          if (name.trim() == "") {
                                                                            Util.toast("请输入文件夹名");
                                                                            return;
                                                                          }
                                                                          Navigator.of(context).pop();
                                                                          String path = paths.join("/").substring(1);
                                                                          var res = await Api.createFolder(path, name);
                                                                          if (res['success']) {
                                                                            Util.toast("文件夹创建成功");
                                                                            refresh();
                                                                          } else {
                                                                            if (res['error']['errors'] != null && res['error']['errors'].length > 0 && res['error']['errors'][0]['code'] == 414) {
                                                                              Util.toast("文件夹创建失败：指定的名称已存在");
                                                                            } else {
                                                                              Util.toast("文件夹创建失败");
                                                                            }
                                                                          }
                                                                        },
                                                                        decoration: NeumorphicDecoration(
                                                                          color: Theme.of(context).scaffoldBackgroundColor,
                                                                          borderRadius: BorderRadius.circular(25),
                                                                        ),
                                                                        bevel: 20,
                                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                                        child: Text(
                                                                          "确定",
                                                                          style: TextStyle(fontSize: 18),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 16,
                                                                    ),
                                                                    Expanded(
                                                                      child: NeuButton(
                                                                        onPressed: () async {
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                        decoration: NeumorphicDecoration(
                                                                          color: Theme.of(context).scaffoldBackgroundColor,
                                                                          borderRadius: BorderRadius.circular(25),
                                                                        ),
                                                                        bevel: 20,
                                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                                        child: Text(
                                                                          "取消",
                                                                          style: TextStyle(fontSize: 18),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          decoration: NeumorphicDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          bevel: 20,
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/icons/new_folder.png",
                                                width: 30,
                                              ),
                                              Text(
                                                "新建文件夹",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: (MediaQuery.of(context).size.width - 100) / 4,
                                        child: NeuButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(CupertinoPageRoute(
                                                builder: (context) {
                                                  return Share(
                                                    paths: [paths.join("/").substring(1)],
                                                    fileRequest: true,
                                                  );
                                                },
                                                settings: RouteSettings(name: "share")));
                                          },
                                          decoration: NeumorphicDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          bevel: 20,
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/icons/upload.png",
                                                width: 30,
                                              ),
                                              Text(
                                                "创建文件请求",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width - 100) / 4,
                                      child: NeuButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).push(CupertinoPageRoute(
                                              builder: (content) {
                                                return ShareManager();
                                              },
                                              settings: RouteSettings(name: "share_manager")));
                                        },
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        bevel: 20,
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              "assets/icons/link.png",
                                              width: 30,
                                            ),
                                            Text(
                                              "共享链接管理",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (paths.length > 1)
                                      SizedBox(
                                        width: (MediaQuery.of(context).size.width - 100) / 4,
                                        child: NeuButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            Navigator.of(context)
                                                .push(CupertinoPageRoute(
                                                    builder: (content) {
                                                      return Search(paths.join("/").substring(1));
                                                    },
                                                    settings: RouteSettings(name: "search")))
                                                .then((res) {
                                              if (res != null) {
                                                search(res['folders'], res['pattern'], res['search_content']);
                                              }
                                            });
                                          },
                                          decoration: NeumorphicDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          bevel: 20,
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/icons/search.png",
                                                width: 30,
                                              ),
                                              Text(
                                                "搜索",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
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
                                bevel: 20,
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
                      ),
                    );
                  },
                );
              },
              child: Image.asset(
                "assets/icons/actions.png",
                width: 20,
                height: 20,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (searchResult)
            Container(
              height: 45,
              color: Theme.of(context).scaffoldBackgroundColor,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 5,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(
                        "搜索结果",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      timer?.cancel();
                      setState(() {
                        searching = false;
                        searchResult = false;
                        refresh();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: NeuCard(
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        bevel: 5,
                        curveType: CurveType.flat,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: searching
                            ? Row(
                                children: [
                                  Text(
                                    "搜索中",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  CupertinoActivityIndicator(
                                    radius: 6,
                                  ),
                                ],
                              )
                            : Text(
                                "退出搜索",
                                style: TextStyle(fontSize: 12),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 45,
              color: Theme.of(context).scaffoldBackgroundColor,
              alignment: Alignment.centerLeft,
              child: ListView.separated(
                controller: _pathScrollController,
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
          if (processing.isNotEmpty) _buildProcessList(),
          Expanded(
            child: success
                ? Stack(
                    children: [
                      listType == ListType.list
                          ? CupertinoScrollbar(
                              child: ListView.builder(
                                controller: _fileScrollController,
                                padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: selectedFiles.length > 0 ? 140 : 20),
                                itemBuilder: (context, i) {
                                  return _buildFileItem(files[i]);
                                },
                                itemCount: files.length,
                              ),
                            )
                          : SingleChildScrollView(
                              controller: _fileScrollController,
                              padding: EdgeInsets.all(20),
                              child: Wrap(
                                runSpacing: 20,
                                spacing: 20,
                                children: files.map(_buildFileItem).toList(),
                              ),
                            ),
                      // if (selectedFiles.length > 0)
                      AnimatedPositioned(
                        bottom: selectedFiles.length > 0 ? 0 : -100,
                        duration: Duration(milliseconds: 200),
                        child: NeuCard(
                          width: MediaQuery.of(context).size.width - 40,
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(10),
                          height: 62,
                          bevel: 20,
                          curveType: CurveType.flat,
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) {
                                      return SelectFolder(
                                        multi: false,
                                      );
                                    },
                                  ).then((folder) async {
                                    if (folder != null && folder.length == 1) {
                                      var res = await Api.copyMoveTask(selectedFiles, folder[0], true);
                                      if (res['success']) {
                                        setState(() {
                                          selectedFiles = [];
                                          multiSelect = false;
                                        });
                                        //获取移动进度
                                        timer = Timer.periodic(Duration(seconds: 1), (_) async {
                                          //获取移动进度
                                          var result = await Api.copyMoveResult(res['data']['taskid']);
                                          if (result['success'] != null && result['success']) {
                                            setState(() {
                                              processing[res['data']['taskid']] = result['data'];
                                            });
                                            if (result['data']['finished']) {
                                              Util.toast("文件移动完成");
                                              timer.cancel();
                                              timer = null;

                                              refresh();
                                              Future.delayed(Duration(seconds: 5)).then((value) {
                                                setState(() {
                                                  processing.remove(res['data']['taskid']);
                                                });
                                              });
                                            }
                                          }
                                        });
                                      }
                                    }
                                  });
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/icons/move.png",
                                      width: 25,
                                    ),
                                    Text(
                                      "移动到",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) {
                                      return SelectFolder(
                                        multi: false,
                                      );
                                    },
                                  ).then((folder) async {
                                    if (folder != null && folder.length == 1) {
                                      var res = await Api.copyMoveTask(selectedFiles, folder[0], false);
                                      if (res['success']) {
                                        setState(() {
                                          selectedFiles = [];
                                          multiSelect = false;
                                        });
                                        //获取复制进度
                                        timer = Timer.periodic(Duration(seconds: 1), (_) async {
                                          //获取复制进度
                                          var result = await Api.copyMoveResult(res['data']['taskid']);
                                          if (result['success'] != null && result['success']) {
                                            setState(() {
                                              processing[res['data']['taskid']] = result['data'];
                                            });
                                            if (result['data']['finished']) {
                                              Util.toast("文件复制完成");
                                              timer.cancel();
                                              timer = null;

                                              refresh();
                                              Future.delayed(Duration(seconds: 5)).then((value) {
                                                setState(() {
                                                  processing.remove(res['data']['taskid']);
                                                });
                                              });
                                            }
                                          }
                                        });
                                      }
                                    }
                                  });
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/icons/copy.png",
                                      width: 25,
                                    ),
                                    Text(
                                      "复制到",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  compressFile(selectedFiles);
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/icons/archive.png",
                                      width: 25,
                                    ),
                                    Text(
                                      "压缩",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  deleteFile(selectedFiles);
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/icons/delete.png",
                                      width: 25,
                                    ),
                                    Text(
                                      "删除",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (loading)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                          child: Center(
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
                          ),
                        ),
                    ],
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
                            bevel: 5,
                            onPressed: () {
                              refresh();
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
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: favoriteLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                  child: Center(
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
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "收藏夹",
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, i) {
                          return _buildFavoriteItem(favorites[i]);
                        },
                        itemCount: favorites.length,
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: paths.length == 1 || multiSelect
          ? null
          : SizedBox(
              width: 60,
              height: 60,
              child: NeuButton(
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(
                          builder: (context) {
                            return Upload(paths.join("/").substring(1));
                          },
                          settings: RouteSettings(name: "upload")))
                      .then((value) {
                    refresh();
                  });
                },
                child: Image.asset(
                  "assets/icons/upload.png",
                  width: 40,
                ),
              ),
            ),
    );
  }
}
