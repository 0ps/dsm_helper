import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';

class UniversalSearch extends StatefulWidget {
  @override
  _UniversalSearchState createState() => _UniversalSearchState();
}

class _UniversalSearchState extends State<UniversalSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("Universal Search"),
      ),
      body: Center(
        child: Text("待开发"),
      ),
    );
  }
}
