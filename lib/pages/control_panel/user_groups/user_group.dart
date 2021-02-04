import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class UserGroups extends StatefulWidget {
  @override
  _UserGroupsState createState() => _UserGroupsState();
}

class _UserGroupsState extends State<UserGroups> {
  List groups = [];
  bool loading = true;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.userGroups();
    if (res['success']) {
      setState(() {
        loading = false;
        groups = res['data']['groups'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("用户群组"),
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
                return _buildGroupItem(groups[i]);
              },
              itemCount: groups.length,
            ),
    );
  }
}
