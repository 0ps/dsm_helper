import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

class Favorite extends StatefulWidget {
  final Function callback;
  Favorite(this.callback);
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  bool favoriteLoading = true;
  List favorites = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
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

  Widget _buildFavoriteItem(favorite) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: NeuButton(
        onPressed: () {
          if (favorite['status'] == "broken") {
            Util.toast("文件或目录不存在");
          } else {
            Navigator.of(context).pop(favorite['path']);
            widget.callback(favorite['path']);
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
              NeuButton(
                onPressed: () {
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
                          decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
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
                                          print(favorite['path']);
                                          TextEditingController nameController = TextEditingController.fromValue(TextEditingValue(text: favorite['name']));
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
                                                                      var res = await Api.favoriteRename(favorite['path'], name);
                                                                      if (res['success']) {
                                                                        Util.toast("重命名成功");
                                                                        getData();
                                                                      } else {
                                                                        if (res['error']['errors'] != null &&
                                                                            res['error']['errors'].length > 0 &&
                                                                            res['error']['errors'][0]['code'] == 414) {
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
                                                  decoration: NeumorphicDecoration(
                                                      color: Theme.of(context).scaffoldBackgroundColor,
                                                      borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        "取消收藏",
                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                                      ),
                                                      SizedBox(
                                                        height: 12,
                                                      ),
                                                      Text(
                                                        "确定取消收藏？",
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
                                                                var res = await Api.favoriteDelete(favorite['path']);
                                                                if (res['success']) {
                                                                  Util.vibrate(FeedbackType.light);
                                                                  Util.toast("取消收藏成功");
                                                                  getData();
                                                                }
                                                              },
                                                              decoration: NeumorphicDecoration(
                                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                                borderRadius: BorderRadius.circular(25),
                                                              ),
                                                              bevel: 5,
                                                              padding: EdgeInsets.symmetric(vertical: 10),
                                                              child: Text(
                                                                "取消收藏",
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
                                        },
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(10),
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
                                              "取消收藏",
                                              style: TextStyle(fontSize: 12),
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
                // padding: EdgeInsets.zero,
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
    return favoriteLoading
        ? Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
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
        : Container(
            height: double.infinity,
            color: Colors.white,
            width: MediaQuery.of(context).size.width * 0.7,
            child: favorites.length > 0
                ? ListView.builder(
                    padding: EdgeInsets.only(left: 20, right: 20, top: MediaQuery.of(context).padding.top),
                    itemBuilder: (context, i) {
                      return _buildFavoriteItem(favorites[i]);
                    },
                    itemCount: favorites.length,
                  )
                : Center(
                    child: Text("暂无收藏"),
                  ),
          );
  }
}
