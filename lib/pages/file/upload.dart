import 'dart:io';

import 'package:dsm_helper/util/function.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Upload extends StatefulWidget {
  final String path;
  Upload(this.path);
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  void initState() {
    print(widget.path);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "文件上传",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      persistentFooterButtons: [
        SizedBox(
          height: 60,
          width: 100,
          child: NeuButton(
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () async {
              FilePickerResult result = await FilePicker.platform.pickFiles();

              if (result != null) {
                print(result.files.single.path);
                //上传文件
                var res = await Api.upload(widget.path, result.files.single.path);
                print(res);
              } else {
                // User canceled the picker
              }
            },
            child: Text("选择文件"),
          ),
        ),
      ],
    );
  }
}
