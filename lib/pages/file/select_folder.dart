import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class SelectFolder extends StatefulWidget {
  final bool multi;
  final bool folder;
  SelectFolder({this.multi = false, this.folder = true});
  @override
  _SelectFolderState createState() => _SelectFolderState();
}

class _SelectFolderState extends State<SelectFolder> {
  ScrollController _scrollController = ScrollController();
  List paths = ["/"];
  List files = [];
  List selectedFiles = [];
  bool loading = true;
  bool success = true;
  String msg = "";
  @override
  void initState() {
    getShareList();
    super.initState();
  }

  getShareList() async {
    setState(() {
      loading = true;
    });
    var res = await Api.shareList();
    setState(() {
      success = res['success'];
    });
    if (res['success']) {
      setState(() {
        loading = false;
        files = res['data']['shares'];
      });
    } else {
      if (loading) {
        setState(() {
          loading = false;
          msg = res['msg'] ?? "加载失败，code:${res['error']['code']}";
        });
      }
    }
  }

  refresh() {
    String path = paths.join("/").substring(1);
    goPath(path);
  }

  getFileList(String path) async {
    setState(() {
      loading = true;
    });
    var res = await Api.fileList(path);
    setState(() {
      success = res['success'];
    });
    if (res['success']) {
      setState(() {
        loading = false;
        files = res['data']['files'];
      });
    } else {
      if (loading) {
        setState(() {
          loading = false;
          msg = res['msg'] ?? "加载失败，code:${res['error']['code']}";
        });
      }
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

  Widget _buildFileItem(file) {
    FileType fileType = Util.fileType(file['name']);
    String path = file['path'];
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Opacity(
        opacity: 1,
        child: NeuButton(
          onPressed: () async {
            if (widget.multi) {
            } else {
              if (file['isdir']) {
                goPath(file['path']);
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
              NeuButton(
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () {
                  setState(() {
                    if (widget.multi) {
                      if (selectedFiles.contains(file['path'])) {
                        selectedFiles.remove(file['path']);
                      } else {
                        selectedFiles.add(file['path']);
                      }
                    } else {
                      selectedFiles = [file['path']];
                    }
                  });
                },
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
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    setState(() {
      selectedFiles = [];
    });
    if (paths.length > 1) {
      paths.removeLast();
      String path = "";

      if (paths.length == 1) {
        path = "/";
      } else {
        path = paths.join("/").substring(1);
      }
      print(path);
      goPath(path);
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Container(
                height: 45,
                color: Theme.of(context).scaffoldBackgroundColor,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
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
                    if (paths.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: NeuButton(
                          onPressed: () {
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
                                          bevel: 5,
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          bevel: 5,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          child: Text(
                            "新建",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: NeuButton(
                        onPressed: paths.length > 1
                            ? () {
                                if (selectedFiles.length > 0) {
                                  Navigator.of(context).pop(selectedFiles);
                                } else {
                                  Navigator.of(context).pop([paths.join("/").substring(1)]);
                                }
                              }
                            : null,
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        bevel: 5,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        child: Text(
                          "选择",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: loading
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
                    : success
                        ? ListView(
                            padding: EdgeInsets.only(bottom: selectedFiles.length > 0 ? 140 : 20),
                            children: files.where((file) => file['isdir']).map(_buildFileItem).toList(),
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
      ),
    );
  }
}
