import 'dart:async';
import 'dart:math';

import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:neumorphic/neumorphic.dart';

class MediaConverter extends StatefulWidget {
  final Map converter;
  MediaConverter(this.converter);
  @override
  _MediaConverterState createState() => _MediaConverterState();
}

class _MediaConverterState extends State<MediaConverter> {
  Timer timer;
  Map converter;
  @override
  void initState() {
    setState(() {
      converter = widget.converter;
    });
    getMediaConverter();
    super.initState();
  }

  getMediaConverter() async {
    var res = await Api.mediaConverter("status");
    if (timer == null) {
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        getMediaConverter();
      });
    }
    if (res['success'] && mounted) {
      setState(() {
        converter = res['data'];
        print(converter);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    print("取消计时器");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: NeuCard(
        width: double.infinity,
        bevel: 5,
        curveType: CurveType.emboss,
        decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "转换进程",
                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 12,
              ),
              NeuCard(
                bevel: 20,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [TextSpan(text: "图像：", style: TextStyle(color: Colors.blue, fontSize: 18)), TextSpan(text: "共 ${converter['photo_total']} 个图像")],
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
                          changeColorValue: 90,
                          changeProgressColor: Colors.red,
                          progressColor: Colors.blue,
                          currentValue: max(converter['photo_remain'] > 0 ? ((converter['photo_total'] - converter['photo_remain']) * 100 / converter['photo_total']).ceil() : 0, converter['thumb_remain'] > 0 ? ((converter['thumb_total'] - converter['thumb_remain']) * 100 / converter['thumb_total']).ceil() : 0),
                          displayText: '%',
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
                bevel: 20,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [TextSpan(text: "视频：", style: TextStyle(color: Colors.blue, fontSize: 18)), TextSpan(text: "共 ${converter['video_total']}个视频")],
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
                          changeColorValue: 90,
                          changeProgressColor: Colors.red,
                          progressColor: Colors.blue,
                          currentValue: converter['video_total'] > 0 ? (converter['video_remain'] * 100 / converter['video_total']).ceil() : 0,
                          displayText: '%',
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
                bevel: 20,
                width: double.infinity,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "状态：", style: TextStyle(color: Colors.blue, fontSize: 18)),
                              TextSpan(
                                text: "${converter['status'] == "converting" ? "转换中" : converter['status'] == "paused" ? "已暂停" : converter['status']}",
                              ),
                              if (converter['resume_time'] > 0) TextSpan(text: " (${DateTime.fromMillisecondsSinceEpoch(converter['resume_time'] * 1000).format("H:i")}恢复)", style: TextStyle(color: Colors.grey)),
                              if (converter['resume_time'] < 0) TextSpan(text: " (无限期延迟)", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (converter['status'] == "paused") {
                            var res = await Api.mediaConverter("resume");
                            if (res['success']) {
                              getMediaConverter();
                            }
                          } else {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return Material(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "延迟转换",
                                            style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop(1);
                                            },
                                            child: NeuCard(
                                              margin: EdgeInsets.only(bottom: 20),
                                              width: double.infinity,
                                              curveType: CurveType.flat,
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              bevel: 20,
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Text(
                                                  "延迟1小时",
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop(3);
                                            },
                                            child: NeuCard(
                                              margin: EdgeInsets.only(bottom: 20),
                                              width: double.infinity,
                                              curveType: CurveType.flat,
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              bevel: 20,
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Text(
                                                  "延迟3小时",
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop(6);
                                            },
                                            child: NeuCard(
                                              margin: EdgeInsets.only(bottom: 20),
                                              width: double.infinity,
                                              curveType: CurveType.flat,
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              bevel: 20,
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Text(
                                                  "延迟6小时",
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop(-1);
                                            },
                                            child: NeuCard(
                                              margin: EdgeInsets.only(bottom: 20),
                                              width: double.infinity,
                                              curveType: CurveType.flat,
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              bevel: 20,
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Text(
                                                  "无限期延迟",
                                                ),
                                              ),
                                            ),
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
                                        ],
                                      ),
                                    ),
                                  );
                                }).then((value) async {
                              if (value != null) {
                                var res = await Api.mediaConverter("pause", hours: value);
                                if (res['success']) {
                                  getMediaConverter();
                                }
                              }
                            });
                          }
                        },
                        child: NeuCard(
                          padding: EdgeInsets.all(10),
                          // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          // padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          curveType: CurveType.flat,
                          bevel: 20,
                          child: Icon(
                            converter['status'] == "paused" ? CupertinoIcons.play_arrow_solid : CupertinoIcons.pause_fill,
                            color: Color(0xffff9813),
                            size: 16,
                          ),
                        ),
                      )
                    ],
                  ),
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
}
