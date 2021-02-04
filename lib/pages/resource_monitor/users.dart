import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("目前连接用户"),
      ),
      body: Center(
        child: Text("开发中……"),
      ),
    );
  }
}
