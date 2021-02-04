import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class UserSetting extends StatefulWidget {
  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _fullnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  Map normalUser;
  bool loading = true;
  bool saving = false;
  Map<String, String> changedData = {
    "username": "",
    "fullname": "",
    "email": "",
    "old_password": "",
    "password": "",
    "confirm_password": "",
  };
  @override
  void initState() {
    getNormalUser();
    super.initState();
  }

  getNormalUser() async {
    var res = await Api.normalUser("get");
    if (res['success']) {
      print(res['data']);
      setState(() {
        loading = false;
        normalUser = res['data'];
      });
      _usernameController.value = TextEditingValue(text: normalUser['username']);
      _fullnameController.value = TextEditingValue(text: normalUser['fullname']);
      _emailController.value = TextEditingValue(text: normalUser['email']);
    } else {
      Util.toast("加载失败，code:${res['error']['code']}");
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("个人设置"),
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
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                NeuCard(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  bevel: 20,
                  curveType: CurveType.flat,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: TextField(
                    controller: _usernameController,
                    onChanged: (v) => changedData['username'] = v,
                    enabled: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '名称',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                NeuCard(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  bevel: 20,
                  curveType: CurveType.flat,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: NeuTextField(
                    controller: _fullnameController,
                    onChanged: (v) => changedData['fullname'] = v,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '描述',
                    ),
                  ),
                ),
                if (!normalUser['disallowchpasswd']) ...[
                  SizedBox(
                    height: 20,
                  ),
                  NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    bevel: 20,
                    curveType: CurveType.flat,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: NeuTextField(
                      onChanged: (v) => changedData['old_password'] = v,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '密码',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    bevel: 20,
                    curveType: CurveType.flat,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: NeuTextField(
                      onChanged: (v) => changedData['password'] = v,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '新密码',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    bevel: 20,
                    curveType: CurveType.flat,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: NeuTextField(
                      onChanged: (v) => changedData['confirm_password'] = v,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '确认密码',
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  height: 20,
                ),
                NeuCard(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  bevel: 20,
                  curveType: CurveType.flat,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: NeuTextField(
                    controller: _emailController,
                    onChanged: (v) => changedData['email'] = v,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '邮箱',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                NeuButton(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () async {
                    if (saving) {
                      return;
                    }
                    setState(() {
                      saving = true;
                    });
                    Map<String, String> data = {};
                    if (changedData['old_password'] == "") {
                      changedData.remove("old_password");
                      changedData.remove("password");
                      changedData.remove("confirm_password");
                    } else {
                      if (changedData['password'] == "") {
                        Util.toast("请输入新密码");
                        return;
                      }
                      if (changedData['confirm_password'] != changedData['password']) {
                        Util.toast("确认密码与新密码不一致");
                        return;
                      }
                    }
                    changedData.forEach((key, value) {
                      if (value.isNotEmpty && key != "confirm_password") {
                        data[key] = value;
                      }
                    });
                    print(data);
                    var res = await Api.normalUser("set", changedData: data);
                    if (res['success']) {
                      Util.toast("保存成功");
                      Navigator.of(context).pop(true);
                    } else {
                      setState(() {
                        saving = false;
                      });
                      Util.toast("保存失败，原因:${res['error']['code']}");
                    }
                  },
                  child: saving
                      ? CupertinoActivityIndicator(
                          radius: 13,
                        )
                      : Text(
                          ' 保存 ',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
    );
  }
}
