import 'dart:async';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class SharedFolders extends StatefulWidget {
  @override
  _SharedFoldersState createState() => _SharedFoldersState();
}

class _SharedFoldersState extends State<SharedFolders> {
  bool loading = true;
  bool success = true;
  String msg = "";
  ScrollController _fileScrollController = ScrollController();
  List folders = [];
  List volumes = [];
  Timer timer;
  @override
  void initState() {
    getVolumes();
    super.initState();
  }

  getVolumes() async {
    var res = await Api.volumes();
    if (res['success']) {
      setState(() {
        volumes = res['data']['volumes'];
      });
      getData();
    }
  }

  getData() async {
    setState(() {
      loading = true;
    });
    var res = await Api.shareCore(additional: [
      "hidden",
      "encryption",
      "is_aclmode",
      "unite_permission",
      "is_support_acl",
      "is_sync_share",
      "is_force_readonly",
      "force_readonly_reason",
      "recyclebin",
      "is_share_moving",
      "is_cluster_share",
      "is_exfat_share",
      "support_snapshot",
      "share_quota",
      "enable_share_compress",
      "enable_share_cow",
    ]);
    setState(() {
      loading = false;
      success = res['success'];
    });
    if (res['success']) {
      folders = res['data']['shares'];
      folders.forEach((folder) {
        volumes.forEach((volume) {
          if (volume['volume_path'] == folder['vol_path']) {
            folder['volume_name'] = volume['display_name'];
            folder['volume_desc'] = volume['description'];
          }
        });
      });
      setState(() {});
    } else {
      if (loading) {
        setState(() {
          msg = res['msg'] ?? "加载失败，code:${res['error']['code']}";
        });
      }
    }
  }

  deleteFolder(String folder) {
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
                  "删除共享文件夹",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "我已了解所选共享文件夹及其快照将被永久删除并无法恢复",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.red),
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
                          var res = await Api.deleteSharedFolderTask([folder]);
                          print(res);
                          if (res['success']) {
                            Util.toast("共享文件夹删除成功");
                          } else {
                            Util.toast("共享文件夹删除出错");
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

  Widget _buildFolderItem(folder) {
    FileType fileType = Util.fileType(folder['name']);
    String path = folder['path'];
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Opacity(
        opacity: 1,
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
              folder['encryption'] == null || folder['encryption'] == 0
                  ? FileIcon(
                      FileType.folder,
                    )
                  : Image.asset(
                      "assets/icons/folder_locked.png",
                      width: 40,
                      height: 40,
                    ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder['name'],
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${folder['volume_name']}(${folder['volume_desc']})",
                      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                    ),
                    if (folder['unite_permission'] != null) ...[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "高级权限：${folder['unite_permission'] ? "已启动" : "已停用"}",
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                      ),
                    ],
                    if (folder['enable_recycle_bin'] != null) ...[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "回收站：${folder['enable_recycle_bin'] ? "已启动" : "已停用"}",
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                      ),
                    ],
                    if (folder['quota_value'] != null) ...[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "共享文件夹配额：${folder['quota_value'] > 0 ? Util.formatSize(folder['quota_value'] * 1024 * 1024) : "已停用"}",
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                      ),
                    ],
                    if (folder['share_quota_used'] != null) ...[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "共享文件夹大小：${Util.formatSize(folder['share_quota_used'] * 1024 * 1024)}",
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                      ),
                    ],
                    if (folder['enable_share_compress'] != null) ...[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "文件压缩：${folder['enable_share_compress'] ? "已启动" : "已禁用"}",
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                      ),
                    ],
                    if (folder['enable_share_cow'] != null) ...[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "数据完整性保护：${folder['enable_share_cow'] ? "已启动" : "已禁用"}",
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              folder['is_share_moving']
                  ? Text("移动中")
                  : NeuButton(
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
                                      height: 12,
                                    ),
                                    if (folder['support_snapshot']) ...[
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
                                          "克隆",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                    ],
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
                                        "编辑",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    if (folder['enable_recycle_bin']) ...[
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
                                          "清空回收站",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                    ],
                                    NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        deleteFolder(folder['name']);
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
              SizedBox(
                width: 20,
              ),
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
        title: Text(
          "共享文件夹",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: success
          ? Stack(
              children: [
                ListView.builder(
                  controller: _fileScrollController,
                  padding: EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, i) {
                    return _buildFolderItem(folders[i]);
                  },
                  itemCount: folders.length,
                ),
                // if (selectedFiles.length > 0)
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
                        getData();
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
    );
  }
}
