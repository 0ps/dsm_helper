import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class AddSharedFolders extends StatefulWidget {
  final List volumes;
  AddSharedFolders(this.volumes);
  @override
  _AddSharedFoldersState createState() => _AddSharedFoldersState();
}

class _AddSharedFoldersState extends State<AddSharedFolders> {
  bool creating = false;
  String name = "";
  String desc = "";
  int selectedVolume = -1;
  _create() async {
    // print(widget.volumes[1]['volume_path']);
    // return;
    setState(() {
      creating = true;
    });

    var res = await Api.addSharedFolder(
      name,
      widget.volumes[1]['volume_path'],
      desc,
    );

    setState(() {
      creating = false;
    });
    if (res['success']) {
      Util.toast("新增共享文件夹成功");
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "新增共享文件夹",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
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
              child: NeuTextField(
                onChanged: (v) => name = v,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '名称',
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
                onChanged: (v) => desc = v,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '描述',
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
              onPressed: _create,
              child: creating
                  ? Center(
                      child: CupertinoActivityIndicator(
                        radius: 13,
                      ),
                    )
                  : Text(
                      ' 新增 ',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
