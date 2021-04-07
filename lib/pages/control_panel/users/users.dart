import 'package:dsm_helper/pages/control_panel/users/user_detail.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List users = [];
  List groups = [];
  bool loading = true;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.users();
    if (res['success']) {
      setState(() {
        users = res['data']['users'];
      });
    } else {
      Util.toast("加载失败");
      Navigator.of(context).pop();
    }
    var group = await Api.userGroups();
    if (group['success']) {
      setState(() {
        loading = false;
        groups = group['data']['groups'];
      });
    } else {
      Util.toast("加载失败");
      Navigator.of(context).pop();
    }
  }

  Widget _buildGroupItem(group) {
    return NeuCard(
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      bevel: 20,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${group['name']}",
                    style: TextStyle(fontSize: 16),
                  ),
                  if (group['description'] != "")
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        "${group['description']}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) {
              return UserDetail(user);
            },
            settings: RouteSettings(name: "user_detail")));
      },
      child: NeuCard(
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.symmetric(vertical: 10),
        bevel: 20,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (user['expired'] == 'normal') Label("正常", Colors.green) else Label("停用", Colors.red),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${user['name']}",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                    if (user['email'] != "")
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          "${user['email']}",
                        ),
                      ),
                    if (user['description'] != "")
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          "${user['description']}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(Util.version < 7 ? "用户账户" : "用户与群组"),
      ),
      body: loading
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              child: Center(
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
              ),
            )
          : Column(
              children: [
                if (Util.version >= 7)
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
                          child: Text("用户账号"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Text("用户群组"),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Util.version < 7
                      ? ListView.builder(
                          padding: EdgeInsets.all(20),
                          itemBuilder: (context, i) {
                            return _buildUserItem(users[i]);
                          },
                          itemCount: users.length,
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemBuilder: (context, i) {
                                return _buildUserItem(users[i]);
                              },
                              itemCount: users.length,
                            ),
                            ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemBuilder: (context, i) {
                                return _buildGroupItem(groups[i]);
                              },
                              itemCount: groups.length,
                            )
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
