import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';

class License extends StatefulWidget {
  const License({Key key}) : super(key: key);

  @override
  _LicenseState createState() => _LicenseState();
}

class _LicenseState extends State<License> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("${Util.appName}用户协议和隐私政策"),
      ),
      body: ListView(
        children: [],
      ),
    );
  }
}
