import 'package:cool_ui/cool_ui.dart';
import 'package:file_station/util/api.dart';
import 'package:file_station/util/function.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String host;
  String account;
  String password;
  bool https = false;
  bool remember = true;
  _login() async {
    var hide = showWeuiLoadingToast(context: context, message: Text("请稍后"), alignment: Alignment.center);
    var res = await Api.login(host: "http://$host:5000", account: account, password: password);
    hide();
    if (res['success'] == true) {
      print("success");
      print(res['data']['sid']);
      //记住登录信息
      Util.setStorage("sid", res['data']['sid']);
      Util.setStorage("host", "http://$host:5000");
      Util.sid = res['data']['sid'];
      Util.baseUrl = "http://$host:5000";
      Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
    } else {
      print(res);
      if (res['error']['code'] == 400) {
        Util.toast("用户名/密码有误");
      } else {
        Util.toast("登录失败，code:${res['error']['code']}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeuAppBar(
        title: Text("File Station"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              curveType: CurveType.flat,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: NeuTextField(
                onChanged: (v) => host = v,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '网址/IP',
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
                onChanged: (v) => account = v,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '账号',
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
              bevel: 12,
              curveType: CurveType.flat,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: NeuTextField(
                onChanged: (v) => password = v,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '密码',
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // SizedBox(
            //   height: 20,
            // ),
            NeuButton(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: _login,
              child: Text(
                ' 登录 ',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
