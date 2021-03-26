import 'package:dsm_helper/pages/control_panel/users/user_detail.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  List users = [];
  bool loading = true;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.users();
    if (res['success']) {
      setState(() {
        loading = false;
        users = res['data']['users'];
      });
    } else {
      Util.toast("加载失败");
      Navigator.of(context).pop();
    }
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
        title: Text("用户账户"),
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
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemBuilder: (context, i) {
                return _buildUserItem(users[i]);
              },
              itemCount: users.length,
            ),
    );
  }
}
