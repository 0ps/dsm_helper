import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class OpenSource extends StatefulWidget {
  @override
  _OpenSourceState createState() => _OpenSourceState();
}

class _OpenSourceState extends State<OpenSource> {
  List list = [
    {
      "name": "cupertino_icons",
      "url": "",
    },
    {
      "name": "neumorphic",
      "url": "",
    },
    {
      "name": "fluttertoast",
      "url": "",
    },
    {
      "name": "package_info",
      "url": "",
    },
    {
      "name": "dio",
      "url": "",
    },
    {
      "name": "flutter_screenutil",
      "url": "",
    },
    {
      "name": "pull_to_refresh",
      "url": "",
    },
    {
      "name": "shared_preferences",
      "url": "",
    },
    {
      "name": "permission_handler",
      "url": "",
    },
    {
      "name": "extended_image",
      "url": "",
    },
    {
      "name": "cool_ui",
      "url": "",
    },
    {
      "name": "gallery_saver",
      "url": "",
    },
    {
      "name": "android_intent",
      "url": "",
    },
    {
      "name": "path_provider",
      "url": "",
    },
    {
      "name": "flutter_downloader",
      "url": "",
    },
    {
      "name": "percent_indicator",
      "url": "",
    },
    {
      "name": "fl_chart",
      "url": "",
    },
    {
      "name": "flutter_animation_progress_bar",
      "url": "",
    },
    {
      "name": "file_picker",
      "url": "",
    },
    {
      "name": "open_file",
      "url": "",
    },
    {
      "name": "flutter_datetime_picker",
      "url": "",
    },
    {
      "name": "flutter_swiper",
      "url": "",
    },
    {
      "name": "html",
      "url": "",
    },
    {
      "name": "flutter_html",
      "url": "",
    },
    {
      "name": "provider",
      "url": "",
    },
    {
      "name": "wave",
      "url": "",
    },
    {
      "name": "dartssh",
      "url": "",
    },
    {
      "name": "xterm",
      "url": "",
    },
    {
      "name": "umeng_analytics_plugin",
      "url": "",
    },
    {
      "name": "photo_manager",
      "url": "",
    },
    {
      "name": "vibrate",
      "url": "",
    },
    {
      "name": "url_launcher",
      "url": "",
    },
    {
      "name": "http",
      "url": "",
    },
    {
      "name": "local_auth",
      "url": "",
    },
    {
      "name": "gesture_password",
      "url": "",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "开源插件",
        ),
      ),
      body: CupertinoScrollbar(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 20),
          separatorBuilder: (context, i) {
            return SizedBox(
              height: 20,
            );
          },
          itemBuilder: (context, i) {
            return NeuCard(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              curveType: CurveType.flat,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      list[i]['name'],
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    NeuButton(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      onPressed: () {
                        AndroidIntent intent = AndroidIntent(
                          action: 'action_view',
                          data: "https://pub.dev/packages/" + list[i]['name'],
                          arguments: {},
                        );

                        intent.launch();
                      },
                      child: Text("详情"),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: list.length,
        ),
      ),
    );
  }
}
