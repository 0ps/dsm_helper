import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  bool loading = true;
  List users = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.currentConnect();
    if (res['success']) {
      setState(() {
        loading = false;
        users = res['data']['items'];
      });
    } else {
      Util.toast("获取目前连接用户失败，代码${res['error']['code']}");
      Navigator.of(context).pop();
    }
  }

  Widget _buildUserItem(user) {
    user['running'] = user['running'] ?? false;
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      curveType: CurveType.flat,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${user['who']}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "${user['time']}",
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      //from
                      Expanded(
                        flex: 2,
                        child: Text(
                          "${user['type']}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "${user['from']}",
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "${user['descr']}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            NeuButton(
              onPressed: () async {
                if (user['running']) {
                  return;
                }
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: Colors.transparent,
                      child: NeuCard(
                        width: double.infinity,
                        bevel: 5,
                        curveType: CurveType.emboss,
                        decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "终止连接",
                                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                "确认要终止此连接？",
                                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: 22,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          user['running'] = true;
                                        });
                                        var res = await Api.kickConnection({"who": user['who'], "from": user['from']});
                                        setState(() {
                                          user['running'] = false;
                                        });

                                        if (res['success']) {
                                          Util.toast("连接已终止");
                                        }
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 5,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        "终止连接",
                                        style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 5,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        "取消",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ],
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
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(5),
              bevel: 5,
              child: SizedBox(
                width: 20,
                height: 20,
                child: user['running']
                    ? CupertinoActivityIndicator()
                    : Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 18,
                      ),
              ),
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
        title: Text("目前连接用户"),
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
                getData();
              },
              child: Icon(Icons.refresh),
            ),
          ),
        ],
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
          : ListView.separated(
              itemBuilder: (context, i) {
                return _buildUserItem(users[i]);
              },
              itemCount: users.length,
              separatorBuilder: (context, i) {
                return SizedBox(
                  height: 20,
                );
              },
            ),
    );
  }
}
