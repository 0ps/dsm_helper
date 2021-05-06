import 'package:dsm_helper/pages/control_panel/public_access/edit_ddns.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class PublicAccess extends StatefulWidget {
  const PublicAccess({Key key}) : super(key: key);

  @override
  _PublicAccessState createState() => _PublicAccessState();
}

class _PublicAccessState extends State<PublicAccess> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List providers = [];
  List records = [];
  String nextUpdateTime = "";
  List ips = [];
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.publicAccessInfo();
    if (res['success']) {
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.Core.DDNS.Provider":
              setState(() {
                providers = item['data']['providers'];
              });
              break;
            case "SYNO.Core.DDNS.Record":
              setState(() {
                records = item['data']['records'];
                nextUpdateTime = item['data']['next_update_time'];
              });
              break;
            case "SYNO.Core.DDNS.ExtIP":
              ips = item['data'];

              break;
          }
        }
      });
    }
  }

  Widget _buildDdnsItem(ddns) {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        //   return EditDdns(ddns);
        // }));
      },
      child: NeuCard(
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        curveType: CurveType.flat,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        bevel: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${ddns['provider']}",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 5,
                ),
                Label(
                  ddns['enable'] ? "正常" : "已停用",
                  ddns['enable'] ? Colors.green : Colors.red,
                  fill: true,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text("${ddns['hostname']}"),
                SizedBox(
                  width: 10,
                ),
                Text("${ddns['ip']}"),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text("上次：${ddns['lastupdated'] == "disabled" ? "已停用" : ddns['lastupdated']}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("外部访问"),
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
              isScrollable: false,
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
                  child: Text("DDNS"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("路由器配置"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("高级设置"),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  itemBuilder: (context, i) {
                    return _buildDdnsItem(records[i]);
                  },
                  itemCount: records.length,
                ),
                Center(
                  child: Text("开发中"),
                ),
                Center(
                  child: Text("开发中"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
