import 'dart:async';

import 'package:android_intent/android_intent.dart';
import 'package:dsm_helper/pages/packages/uninstall.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:neumorphic/neumorphic.dart';

class PackageDetail extends StatefulWidget {
  final Map package;
  PackageDetail(this.package);
  @override
  _PackageDetailState createState() => _PackageDetailState();
}

class _PackageDetailState extends State<PackageDetail> {
  String thumbnailUrl = "";
  String installVolume = "";
  List volumes = [];
  double installProgress = 0;
  bool installing = false;
  Timer timer;
  String taskId = "";
  String installButtonText = "安装";
  @override
  void initState() {
    if (widget.package['installed'] && widget.package['additional'] != null) {
      List paths = widget.package['additional']['installed_info']['path'].split("/");
      setState(() {
        installVolume = paths[1].replaceAll("volume", "存储空间 ");
      });
    }

    thumbnailUrl = widget.package['thumbnail'].last;
    if (!thumbnailUrl.startsWith("http")) {
      thumbnailUrl = Util.baseUrl + thumbnailUrl;
    }
    getVolumes();
    super.initState();
  }

  getVolumes() async {
    var res = await Api.volumes();
    if (res['success']) {
      setState(() {
        volumes = res['data']['volumes'];
      });
    }
  }

  Widget _buildSwiperItem(String url) {
    if (!url.startsWith("http")) {
      url = Util.baseUrl + url;
    }
    return CupertinoExtendedImage(
      url,
      height: 210,
      fit: BoxFit.contain,
    );
  }

  getLaunchedPackages() async {
    print("获取运行中套件");
    var res = await Api.launchedPackages();
    print("获取运行中套件end");
    if (res['success']) {
      Map packages = res['data']['packages'];
      packages.forEach((key, value) {
        if (key == widget.package['id']) {
          setState(() {
            widget.package['launched'] = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.package['dname']}",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                NeuCard(
                  curveType: CurveType.flat,
                  bevel: 20,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CupertinoExtendedImage(
                          thumbnailUrl,
                          width: 60,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${widget.package['dname']}"),
                              if (widget.package['installed'])
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: widget.package['launched'] ? Label("已启动", Colors.green) : Label("已停用", Colors.red),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (widget.package['snapshot'] != null && widget.package['snapshot'].length > 0)
                  NeuCard(
                    margin: EdgeInsets.only(top: 20),
                    curveType: CurveType.flat,
                    bevel: 20,
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 210,
                            child: Swiper(
                              autoplay: true,
                              autoplayDelay: 5000,
                              pagination: SwiperPagination(alignment: Alignment.bottomCenter, builder: DotSwiperPaginationBuilder(activeColor: Colors.lightBlueAccent, size: 7, activeSize: 7)),
                              itemCount: widget.package['snapshot'].length,
                              itemBuilder: (context, i) {
                                return _buildSwiperItem(widget.package['snapshot'][i]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                NeuCard(
                  margin: EdgeInsets.only(top: 20),
                  curveType: CurveType.flat,
                  bevel: 20,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "描述",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text("${widget.package['desc']}"),
                      ],
                    ),
                  ),
                ),
                if (widget.package['changelog'] != "")
                  NeuCard(
                    margin: EdgeInsets.only(top: 20),
                    curveType: CurveType.flat,
                    bevel: 20,
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.package['version']}新增功能",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          Html(
                            data: widget.package['changelog'],
                            onLinkTap: (link) {
                              AndroidIntent intent = AndroidIntent(
                                action: 'action_view',
                                data: link,
                                arguments: {},
                              );
                              intent.launch();
                            },
                            style: {
                              "ol": Style(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                              ),
                              "li": Style(),
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                NeuCard(
                  margin: EdgeInsets.only(top: 20),
                  curveType: CurveType.flat,
                  bevel: 20,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "其他信息",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            NeuCard(
                              width: (MediaQuery.of(context).size.width - 100) / 2,
                              curveType: CurveType.flat,
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              bevel: 20,
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("开发者"),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (widget.package['maintainer_url'] != null && widget.package['maintainer_url'] != "")
                                    GestureDetector(
                                      child: Text(
                                        "${widget.package['maintainer']}",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onTap: () {
                                        AndroidIntent intent = AndroidIntent(
                                          action: 'action_view',
                                          data: widget.package['maintainer_url'],
                                          arguments: {},
                                        );
                                        intent.launch();
                                      },
                                    )
                                  else
                                    Text(
                                      "${widget.package['maintainer']}",
                                    ),
                                ],
                              ),
                            ),
                            if (widget.package['distributor'] != null && widget.package['distributor'] != "")
                              NeuCard(
                                width: (MediaQuery.of(context).size.width - 100) / 2,
                                curveType: CurveType.flat,
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                bevel: 20,
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("发布人员"),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    if (widget.package['distributor_url'] != null && widget.package['distributor_url'] != "")
                                      GestureDetector(
                                        child: Text(
                                          "${widget.package['distributor']}",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        onTap: () {
                                          AndroidIntent intent = AndroidIntent(
                                            action: 'action_view',
                                            data: widget.package['distributor_url'],
                                            arguments: {},
                                          );
                                          intent.launch();
                                        },
                                      )
                                    else
                                      Text(
                                        "${widget.package['distributor']}",
                                      ),
                                  ],
                                ),
                              ),
                            NeuCard(
                              width: (MediaQuery.of(context).size.width - 100) / 2,
                              curveType: CurveType.flat,
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              bevel: 20,
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("下载次数"),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text("${widget.package['download_count']}"),
                                ],
                              ),
                            ),
                            if (widget.package['installed'])
                              NeuCard(
                                width: (MediaQuery.of(context).size.width - 100) / 2,
                                curveType: CurveType.flat,
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                bevel: 20,
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("已安装版本"),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("${widget.package['installed_version']}"),
                                  ],
                                ),
                              ),
                            if (widget.package['installed'])
                              NeuCard(
                                width: (MediaQuery.of(context).size.width - 100) / 2,
                                curveType: CurveType.flat,
                                decoration: NeumorphicDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                bevel: 20,
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("安装位置"),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("$installVolume"),
                                  ],
                                ),
                              ),
                            NeuCard(
                              width: (MediaQuery.of(context).size.width - 100) / 2,
                              curveType: CurveType.flat,
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              bevel: 20,
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("最新版本"),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text("${widget.package['version']}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              children: [
                if (widget.package['installed']) ...[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: NeuButton(
                        onPressed: () {
                          if (widget.package['additional']['is_uninstall_pages']) {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                              return UninstallPackage(widget.package);
                            }));
                          } else {
                            Util.toast("无需卸载页");
                          }
                        },
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          "卸载",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: widget.package['launched']
                          ? NeuButton(
                              onPressed: () async {
                                var res = await Api.launchPackage(widget.package['id'], widget.package['dsm_apps'], "stop");
                                if (res['success']) {
                                  Util.toast("已停用");
                                  setState(() {
                                    widget.package['launched'] = false;
                                  });
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text("停用"),
                            )
                          : NeuButton(
                              onPressed: () async {
                                var res = await Api.launchPackage(widget.package['id'], widget.package['dsm_apps'], "start");
                                if (res['success']) {
                                  Util.toast("已启动");
                                  setState(() {
                                    widget.package['launched'] = true;
                                  });
                                } else {
                                  Util.toast("套件启动失败，代码${res['error']['code']}");
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text("启动"),
                            ),
                    ),
                  ),
                ] else
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: NeuButton(
                        onPressed: () {
                          if (installing) {
                            Util.toast("套件安装中，请稍后");
                            return;
                          }
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return Material(
                                color: Colors.transparent,
                                child: NeuCard(
                                  width: double.infinity,
                                  bevel: 20,
                                  curveType: CurveType.emboss,
                                  decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          "选择套件安装位置",
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        ...volumes.map((volume) {
                                          return Padding(
                                            padding: EdgeInsets.only(bottom: 20),
                                            child: NeuButton(
                                              onPressed: () async {
                                                var res = await Api.installPackageTask(widget.package['id'], volume['volume_path']);
                                                if (res['success']) {
                                                  Util.toast("已开始安装");

                                                  setState(() {
                                                    installing = true;
                                                    installProgress = double.parse(res['data']['progress']);
                                                    taskId = res['data']['taskid'];
                                                    installButtonText = "下载中:${installProgress.toStringAsFixed(2)}%";
                                                  });
                                                  timer = Timer.periodic(Duration(seconds: 5), (timer) {
                                                    Api.installPackageStatus(res['data']['taskid']).then((value) {
                                                      setState(() {
                                                        installing = !value['data']['finished'];
                                                        if (value['data']['finished']) {
                                                          widget.package['installed'] = true;
                                                          getLaunchedPackages();
                                                          timer.cancel();
                                                        } else if (value['data']['progress'] != null) {
                                                          if (value['data']['progress'] is double) {
                                                            installProgress = value['data']['progress'];
                                                          } else {
                                                            installProgress = double.parse(value['data']['progress']);
                                                          }
                                                          installButtonText = "下载中:${installProgress.toStringAsFixed(2)}%";
                                                        } else if (value['data']['status'] == "installing") {
                                                          installButtonText = "安装中……";
                                                        }
                                                      });
                                                    });
                                                  });
                                                } else {
                                                  Util.toast("安装套件失败，代码${res['error']['code']}");
                                                }
                                                Navigator.of(context).pop();
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 20,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Container(
                                                padding: EdgeInsets.only(left: 20),
                                                width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("${volume['display_name']}(可用容量：${Util.formatSize(int.parse(volume['size_free_byte']))}) - ${volume['fs_type']}"),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "${volume['description']}",
                                                      style: TextStyle(color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
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
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text("$installButtonText"),
                      ),
                    ),
                  ),
                if (widget.package['can_update'])
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: NeuButton(
                        onPressed: () {
                          Util.toast("暂不支持安装套件，敬请期待");
                        },
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text("更新"),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
