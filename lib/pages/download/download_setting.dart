import 'dart:io';

import 'package:dsm_helper/pages/common/select_local_folder.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadSetting extends StatefulWidget {
  @override
  _DownloadSettingState createState() => _DownloadSettingState();
}

class _DownloadSettingState extends State<DownloadSetting> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("下载选项"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          if (Platform.isAndroid) ...[
            NeuButton(
              onPressed: () async {
                bool permission = false;
                permission = await Permission.storage.request().isGranted;
                if (!permission) {
                  Util.toast("请先授权APP访问存储权限");
                  return;
                }
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return SelectLocalFolder(
                      multi: false,
                    );
                  },
                ).then((res) {
                  if (res != null && res.length == 1) {
                    setState(() {
                      Util.downloadSavePath = res[0];
                      Util.setStorage("download_save_path", res[0]);
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "下载位置",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          height: 20,
                          child: Text(
                            Util.downloadSavePath,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
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
        ],
      ),
    );
  }
}
