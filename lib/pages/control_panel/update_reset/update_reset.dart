import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateReset extends StatefulWidget {
  @override
  _UpdateResetState createState() => _UpdateResetState();
}

class _UpdateResetState extends State<UpdateReset> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String firmwareDate = "";
  String firmwareVer = "";
  String model = "";
  Map update;
  bool checking = true;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    getData();
    checkUpdate();
    super.initState();
  }

  getData() async {
    var res = await Api.firmwareVersion();
    print(res);
    if (res['success']) {
      setState(() {
        firmwareDate = res['data']['firmware_date'];
        firmwareVer = res['data']['firmware_ver'];
        model = res['data']['model'];
      });
    }
  }

  checkUpdate() async {
    var res = await Api.firmwareUpgrade();
    setState(() {
      checking = false;
    });
    print(res);
    if (res['success']) {
      setState(() {
        update = res['data']['update'];
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("更新和还原"),
      ),
      body: Column(
        children: [
          NeuCard(
            width: double.infinity,
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            curveType: CurveType.flat,
            bevel: 10,
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              unselectedLabelColor: Colors.grey,
              indicator: BubbleTabIndicator(
                indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                shadowColor: Util.getAdjustColor(Theme.of(context).scaffoldBackgroundColor, -20),
              ),
              tabs: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("系统更新"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("系统设置备份"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("重置"),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    Text(
                      "Synology 会不时发布 DSM 更新。安装更新版本的 DSM 以获得新功能、安全补丁以及改进的系统稳定性。",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    NeuCard(
                      curveType: CurveType.flat,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 20,
                      padding: EdgeInsets.all(20),
                      child: Text("产品型号: $model"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    NeuCard(
                      curveType: CurveType.flat,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 20,
                      padding: EdgeInsets.all(20),
                      child: Text("DSM 版本: $firmwareVer"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    NeuCard(
                      curveType: CurveType.flat,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 20,
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text("状态: "),
                          checking
                              ? CupertinoActivityIndicator()
                              : update != null
                                  ? Row(
                                      children: [
                                        Text(
                                          "${update['version']}版本可下载",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            String url = "http://update.synology.com/autoupdate/whatsnew.php?model=${Uri.encodeComponent(model)}&update_version=${update['version_details']['buildnumber']}-0";
                                            print(url);
                                            launch(url);
                                          },
                                          child: Text(
                                            " (说明)",
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "无更新",
                                    ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "为保证系统稳定性，此处仅作展示，请至WEB控制端进行更新",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                Center(
                  child: Text("待开发"),
                ),
                Center(
                  child: Text("待开发"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
