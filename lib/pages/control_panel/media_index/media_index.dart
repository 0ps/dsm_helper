import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'dart:async';

class MediaIndex extends StatefulWidget {
  @override
  _MediaIndexState createState() => _MediaIndexState();
}

class _MediaIndexState extends State<MediaIndex> {
  bool mediaIndexing;
  String thumbnailQuality = "";
  bool mobileEnabled;
  List packages = [];
  Timer timer;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    if (timer == null) {
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        getData();
      });
    }
    Api.mediaIndexStatus().then((res) {
      if (res['success']) {
        List result = res['data']['result'];
        result.forEach((item) {
          if (item['success'] == true) {
            switch (item['api']) {
              case "SYNO.Core.MediaIndexing":
                setState(() {
                  mediaIndexing = item['data']['reindexing'];
                });
                break;
              case "SYNO.Core.MediaIndexing.ThumbnailQuality":
                setState(() {
                  thumbnailQuality = item['data']['thumbnail_quality'];
                  packages = item['data']['packages'];
                });
                break;
              case "SYNO.Core.MediaIndexing.MobileEnabled":
                setState(() {
                  mobileEnabled = item['data']['mobile_profile_enabled'];
                });
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("索引服务"),
      ),
      body: ListView(
        children: [
          NeuCard(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            bevel: 10,
            curveType: CurveType.flat,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "媒体索引",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      Text(
                        "${mediaIndexing == null ? "加载中" : mediaIndexing ? "索引中" : "已完成"}",
                        style: TextStyle(
                            color: mediaIndexing == null
                                ? null
                                : mediaIndexing
                                    ? Colors.blue
                                    : Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("媒体索引功能会自动扫描存储在 DiskStation 中的多媒体文件如照片、音乐和视频，并为这些文件创建索引以供多媒体应用程序使用。"),
                      SizedBox(
                        height: 5,
                      ),
                      Text("请注意，只有“/photo”共享文件夹内的图像文件才会在创建索引后添加到 Photo Station。"),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text("应用程序：${packages.map((e) => e['name']).join("，")}"),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      NeuButton(
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        bevel: 10,
                        onPressed: () async {
                          if (mediaIndexing) {
                            return;
                          }
                          var res = await Api.mediaReindex();
                          if (res['success']) {
                            getData();
                          }
                        },
                        child: Text(
                          "重建索引",
                          style: TextStyle(color: mediaIndexing == null || mediaIndexing == true ? Colors.grey : null),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          NeuCard(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            bevel: 10,
            curveType: CurveType.flat,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "缩图设置",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("当您上传照片或视频供媒体服务器和 Photo Station 使用时，系统会创建缩略图来提供更好的浏览体验。您可以在此设置缩略图品质并查看创建进程。"),
                      SizedBox(
                        height: 5,
                      ),
                      Text("注意: 创建高品质缩略图将耗用较多的时间。"),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text("缩图品质："),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  thumbnailQuality = "normal";
                                });
                                await Api.mediaIndexSet(thumbnailQuality, mobileEnabled);
                                getData();
                              },
                              child: NeuCard(
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(10),
                                bevel: 10,
                                curveType: thumbnailQuality == "normal" ? CurveType.emboss : CurveType.flat,
                                child: Row(
                                  children: [
                                    Text("一般品质"),
                                    Spacer(),
                                    if (thumbnailQuality == "normal")
                                      Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  thumbnailQuality = "high";
                                });
                                await Api.mediaIndexSet(thumbnailQuality, mobileEnabled);
                                getData();
                              },
                              child: NeuCard(
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(10),
                                bevel: 10,
                                curveType: thumbnailQuality == "high" ? CurveType.emboss : CurveType.flat,
                                child: Row(
                                  children: [
                                    Text("高品质"),
                                    Spacer(),
                                    if (thumbnailQuality == "high")
                                      Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Color(0xffff9813),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (mobileEnabled != null)
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              bevel: 10,
              curveType: CurveType.flat,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "视频设置",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("若要在移动设备上查看 Photo Station 中“photo”共享文件夹内的视频，您可以为移动设备启用视频格式转换的功能。"),
                        SizedBox(
                          height: 5,
                        ),
                        Text("注意: 启用此选项将耗用较多的时间和 CPU 资源。"),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              mobileEnabled = !mobileEnabled;
                            });
                            await Api.mediaIndexSet(thumbnailQuality, mobileEnabled);
                            getData();
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(10),
                            bevel: 10,
                            curveType: mobileEnabled ? CurveType.emboss : CurveType.flat,
                            child: Row(
                              children: [
                                Text("启用移动设备视频转换"),
                                Spacer(),
                                if (mobileEnabled)
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
