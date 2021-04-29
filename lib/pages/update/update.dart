import 'package:dio/dio.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:open_file/open_file.dart';
import 'package:dsm_helper/util/function.dart';

class Update extends StatefulWidget {
  final Map data;
  final bool direct;
  Update(this.data, {this.direct: false});
  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  bool downloading = false;
  bool exist = false;
  CancelToken cancelToken = CancelToken();
  double progress = 0;
  bool loading = true;
  String fileName = "";
  String filePath = "";
  int downloadedSize = 0;
  int totalSize = 0;
  @override
  void initState() {
    fileName = "dsm_helper-${widget.data['build']}.apk";
    Util.fileExist(fileName).then((res) {
      setState(() {
        if (res != null) {
          exist = true;
          filePath = res;
        }
        loading = false;
      });
    });
    if (widget.direct) {
      download();
    }
    super.initState();
  }

  download() async {
    setState(() {
      downloading = true;
    });
    cancelToken = CancelToken();
    var res = await Util.downloadPkg(fileName, widget.data['url'], (downloaded, total) {
      setState(() {
        downloadedSize = downloaded;
        totalSize = total;
        progress = downloaded / total;
      });
    }, cancelToken);
    if (res['code'] == 1) {
      setState(() {
        exist = true;
        filePath = res['data'];
      });
      install();
    } else {
      Util.toast(res['msg']);
    }
    setState(() {
      downloading = false;
    });
  }

  install() async {
    //检查安装权限
    await OpenFile.open(filePath);
  }

  cancel() {
    setState(() {
      downloading = false;
      progress = 0;
    });
    cancelToken.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(
          "软件更新",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: NeuCard(
                    bevel: 20,
                    curveType: CurveType.flat,
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(
                        "assets/logo.png",
                      ),
                      radius: 60,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    Text(
                      "新版本 v${widget.data['version']} build ${widget.data['build']}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "更新时间：${DateTime.fromMillisecondsSinceEpoch(widget.data['update_time'] * 1000).format("Y-m-d H:i")}",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "安装包大小：${Util.formatSize(widget.data['size'])}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                NeuCard(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  curveType: CurveType.flat,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "更新日志：",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${widget.data['note'] ?? "暂无更新日志"}",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (exist && !downloading) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  progress = 0;
                });
                download();
              },
              child: Text(
                "重新下载",
                style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline, fontSize: 14),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
          if (!downloading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: NeuButton(
                onPressed: () {
                  if (exist) {
                    install();
                  } else if (downloading) {
                    cancel();
                  } else {
                    download();
                  }
                },
                // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: Text(
                  exist ? "开始安装" : "开始下载",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          if (downloading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: NeuCard(
                curveType: CurveType.flat,
                bevel: 10,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FAProgressBar(
                    backgroundColor: Colors.transparent,
                    progressColor: Colors.blue,
                    currentValue: (progress * 100).ceil(),
                    size: 64,
                    borderRadius: BorderRadius.circular(20),
                    displayText: '%',
                    displayTextStyle: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
