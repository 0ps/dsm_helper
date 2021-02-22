import 'dart:io';

import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Browser extends StatefulWidget {
  final String url;
  final String title;
  Browser({this.url, this.title});
  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(widget.title ?? "浏览网页"),
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
                launch(widget.url);
              },
              child: Image.asset(
                "assets/icons/browser.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
      body: WebView(
        initialUrl: widget.url,
        onPageFinished: (v) {
          print(v);
        },
      ),
    );
  }
}
