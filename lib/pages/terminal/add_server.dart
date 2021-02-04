import 'dart:convert';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class AddServer extends StatefulWidget {
  @override
  _AddServerState createState() => _AddServerState();
}

class _AddServerState extends State<AddServer> {
  List servers = [];

  String host = "";
  String account = "";
  String password = "";
  String port = "22";

  TextEditingController _hostController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _portController = TextEditingController(text: "22");

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    String str = await Util.getStorage("terminal_servers");
    setState(() {
      if (str.isNotBlank) {
        servers = json.decode(str);
      } else {
        servers = [];
      }
    });
    // print(servers);
  }

  _save() async {
    // print(servers);
    //添加服务器记录
    bool exist = false;
    for (int i = 0; i < servers.length; i++) {
      if (servers[i]['host'] == host && servers[i]['port'] == port && servers[i]['account'] == account) {
        print("账号已存在，更新信息");
        servers[i]['password'] = password;
        exist = true;
      }
    }
    if (!exist) {
      print("账号不存在");
      Map server = {
        "host": host,
        "port": port,
        "account": account,
        "password": password,
      };
      servers.add(server);
    }
    // print(servers);
    Util.setStorage("terminal_servers", jsonEncode(servers));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("添加服务器"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
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
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: NeuTextField(
                      controller: _hostController,
                      onChanged: (v) => host = v,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '网址/IP',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: NeuTextField(
                      onChanged: (v) => port = v,
                      controller: _portController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '端口',
                      ),
                    ),
                  ),
                ],
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
                controller: _accountController,
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
                controller: _passwordController,
                onChanged: (v) => password = v,
                obscureText: true,
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
              onPressed: _save,
              child: Text(
                ' 保存 ',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
