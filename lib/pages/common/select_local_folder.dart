import 'dart:io';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class SelectLocalFolder extends StatefulWidget {
  final bool multi;
  final bool folder;
  SelectLocalFolder({this.multi = false, this.folder = true});
  @override
  _SelectLocalFolderState createState() => _SelectLocalFolderState();
}

class _SelectLocalFolderState extends State<SelectLocalFolder> {
  ScrollController _scrollController = ScrollController();
  List paths = ["/"];
  List<FileSystemEntity> files = [];
  List selectedFiles = [];
  String msg = "";
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    Directory directory;
    if (paths.length == 1) {
      directory = Directory("/storage/emulated/0/");
    } else {
      directory = Directory("/storage/emulated/0" + paths.join("/").substring(1));
    }
    print("getData:${directory.path}");
    files = [];
    await directory.list().forEach((element) {
      if (!FileSystemEntity.isFileSync(element.path) && !element.path.split("/").last.startsWith(".")) {
        files.add(element);
      }
    });
    files.sort((a, b) {
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });
    setState(() {});
  }

  goPath(String path) async {
    print("goPath:${path}");
    path = path.replaceAll("/storage/emulated/0", "");
    setPaths(path);
    await getData();
    double offset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(offset, duration: Duration(milliseconds: 200), curve: Curves.ease);
  }

  setPaths(String path) {
    print("setPath:${path}");
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
    print("setPathEnd:${paths}");
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
            path = items.join("/");
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
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Opacity(
        opacity: 1,
        child: NeuButton(
          onPressed: () async {
            goPath(file.path);
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
              FileIcon(
                FileType.folder,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  file.path.split("/").last,
                  style: TextStyle(
                    fontSize: 16,
                  ),
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
                      if (selectedFiles.contains(file.path)) {
                        selectedFiles.remove(file.path);
                      } else {
                        selectedFiles.add(file.path);
                      }
                    } else {
                      selectedFiles = [file.path];
                    }
                  });
                },
                padding: EdgeInsets.all(5),
                bevel: 5,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: selectedFiles.contains(file.path)
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
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: NeuButton(
                        onPressed: paths.length > 1
                            ? () {
                                if (selectedFiles.length > 0) {
                                  Navigator.of(context).pop(selectedFiles);
                                } else {
                                  Navigator.of(context).pop(["/storage/emulated/0" + paths.join("/").substring(1)]);
                                }
                              }
                            : null,
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        bevel: 5,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          "完成",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
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
                child: ListView(
                  padding: EdgeInsets.only(bottom: selectedFiles.length > 0 ? 140 : 20),
                  children: files.map(_buildFileItem).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
