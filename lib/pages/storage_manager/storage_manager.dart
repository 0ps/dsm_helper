import 'package:flutter/material.dart';

class StorageManager extends StatefulWidget {
  @override
  _StorageManagerState createState() => _StorageManagerState();
}

class _StorageManagerState extends State<StorageManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("存储空间管理员"),
      ),
      body: Center(
        child: Text("待开发"),
      ),
    );
  }
}
