import 'package:file_station/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Files extends StatefulWidget {
  @override
  _FilesState createState() => _FilesState();
}

class _FilesState extends State<Files> {
  List shares = [];
  @override
  void initState() {
    getShareList();
    super.initState();
  }

  getShareList() async {
    var res = await Api.stareList();
    if (res['success']) {
      setState(() {
        shares = res['data']['shares'];
      });
    }
  }

  Widget _buildFileItem(file) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      child: NeuButton(
        onPressed: () {},
        // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Image.asset(
              "assets/icons/folder.png",
              width: 40,
              height: 40,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file['name'],
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateTime.fromMillisecondsSinceEpoch(file['additional']['time']['crtime'] * 1000).format("Y-m-d H:i:s"),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.headline5.color),
                  ),
                ],
              ),
            ),
            NeuCard(
              padding: EdgeInsets.only(left: 5, right: 3, top: 4, bottom: 4),
              decoration: NeumorphicDecoration(
                color: Color(0xfff0f0f0),
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 2,
              child: Icon(CupertinoIcons.right_chevron),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "文件",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, i) {
          return _buildFileItem(shares[i]);
        },
        itemCount: shares.length,
      ),
    );
  }
}
