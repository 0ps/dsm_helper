import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';

class EditDdns extends StatefulWidget {
  final Map ddns;
  const EditDdns(this.ddns, {Key key}) : super(key: key);

  @override
  _EditDdnsState createState() => _EditDdnsState();
}

class _EditDdnsState extends State<EditDdns> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("DDNS"),
      ),
    );
  }
}
