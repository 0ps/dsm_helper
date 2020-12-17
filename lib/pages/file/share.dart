import 'dart:convert';

import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Share extends StatefulWidget {
  final List<String> paths;
  Share(this.paths);
  @override
  _ShareState createState() => _ShareState();
}

class _ShareState extends State<Share> {
  bool loading = true;
  List links;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.createShare(widget.paths);
    print(res);
    if (res['success']) {
      setState(() {
        loading = false;
        links = res['data']['links'];
        print(links);
      });
    }
  }

  Widget _buildLinkItem(link) {
    return Container(
      child: Column(
        children: [
          Image.memory(Base64Decoder().convert(link['qrcode'].split(",")[1])),
          Text(link['path']),
          Text(link['url']),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "分享文件",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: loading
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
          : ListView.builder(
              itemBuilder: (context, i) {
                return _buildLinkItem(links[i]);
              },
              itemCount: links.length,
            ),
    );
  }
}
