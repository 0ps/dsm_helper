import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';

class SecurityScan extends StatefulWidget {
  @override
  _SecurityScanState createState() => _SecurityScanState();
}

class _SecurityScanState extends State<SecurityScan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("安全顾问"),
      ),
      body: Center(
        child: Text("待开发"),
      ),
    );
  }
}
