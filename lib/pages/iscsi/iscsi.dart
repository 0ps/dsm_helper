import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';

class ISCSIManger extends StatefulWidget {
  @override
  _ISCSIMangerState createState() => _ISCSIMangerState();
}

class _ISCSIMangerState extends State<ISCSIManger> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("iSCSI Manager"),
      ),
      body: Center(
        child: Text("待开发"),
      ),
    );
  }
}
