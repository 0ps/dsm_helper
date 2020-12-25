import 'package:android_intent/android_intent.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/label.dart';
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
    super.initState();
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
      body: ListView(
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
    );
  }
}
