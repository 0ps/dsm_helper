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
  TextEditingController volumeController;
  bool creating = false;
  String name = "";
  String desc = "";
  int selectedVolumeIndex = 0;
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
        child: Column(
          children: [
            Expanded(
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
                  GestureDetector(
                    onTap: () {
                      print(widget.volumes);
                      FocusScope.of(context).requestFocus(FocusNode());
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return Material(
                            color: Colors.transparent,
                            child: NeuCard(
                              width: double.infinity,
                              padding: EdgeInsets.all(22),
                              bevel: 5,
                              curveType: CurveType.emboss,
                              decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "选择所在位置",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  ...widget.volumes.map((volume) {
                                    return NeuCard(
                                      padding: EdgeInsets.all(20),
                                      bevel: 20,
                                      curveType: CurveType.flat,
                                      decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                                      child: Column(
                                        children: [
                                          Text(volume['display_name']),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "取消",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 12,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        controller: volumeController,
                        decoration: InputDecoration(
                          enabled: false,
                          border: InputBorder.none,
                          labelText: "所在位置",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: NeuButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
