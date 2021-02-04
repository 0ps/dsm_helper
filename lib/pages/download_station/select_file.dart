import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class SelectFile extends StatefulWidget {
  final List listId;
  final String destination;
  SelectFile(this.listId, this.destination);
  @override
  _SelectFileState createState() => _SelectFileState();
}

class _SelectFileState extends State<SelectFile> {
  String title = "";
  List files = [];
  List selectedFiles = [];
  int size = 0;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.downloadFileList(widget.listId[0]);
    if (res['success']) {
      setState(() {
        title = res['data']['title'];
        files = res['data']['files'];
        files.forEach((element) {
          selectedFiles.add(element['index']);
        });
        size = res['data']['size'];
      });
    } else {
      Util.toast("获取文件列表失败，代码${res['error']['code']}");
    }
  }

  Widget _buildFileItem(file) {
    FileType fileType = Util.fileType(file['name']);
    return GestureDetector(
      onTap: () {
        if (selectedFiles.contains(file['index'])) {
          setState(() {
            selectedFiles.remove(file['index']);
          });
        } else {
          setState(() {
            selectedFiles.add(file['index']);
          });
        }
      },
      child: NeuCard(
        curveType: CurveType.flat,
        bevel: 20,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              SizedBox(
                width: 20,
              ),
              FileIcon(
                fileType, //file['isdir'] ? FileType.folder :
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
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${Util.formatSize(file['size'])}",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              NeuCard(
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                curveType: selectedFiles.contains(file['index']) ? CurveType.emboss : CurveType.flat,
                padding: EdgeInsets.all(5),
                bevel: 5,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: selectedFiles.contains(file['index'])
                      ? Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Color(0xffff9813),
                        )
                      : null,
                ),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("选择下载文件"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          NeuCard(
            curveType: CurveType.flat,
            bevel: 20,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$title"),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "${Util.formatSize(size)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // NeuCard(
          //   curveType: CurveType.flat,
          //   bevel: 20,
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          //   decoration: NeumorphicDecoration(
          //     color: Theme.of(context).scaffoldBackgroundColor,
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //     child: Row(
          //       children: [
          //         NeuCard(
          //           curveType: CurveType.flat,
          //           bevel: 5,
          //           margin: EdgeInsets.only(right: 20),
          //           decoration: NeumorphicDecoration(
          //             color: Theme.of(context).scaffoldBackgroundColor,
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //           child: Text("全部"),
          //         ),
          //         NeuCard(
          //           curveType: CurveType.flat,
          //           bevel: 5,
          //           margin: EdgeInsets.only(right: 20),
          //           decoration: NeumorphicDecoration(
          //             color: Theme.of(context).scaffoldBackgroundColor,
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //           child: Text("视频"),
          //         ),
          //         NeuCard(
          //           curveType: CurveType.flat,
          //           bevel: 5,
          //           margin: EdgeInsets.only(right: 20),
          //           decoration: NeumorphicDecoration(
          //             color: Theme.of(context).scaffoldBackgroundColor,
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //           child: Text("图片"),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, i) {
                return _buildFileItem(files[i]);
              },
              itemCount: files.length,
              separatorBuilder: (context, i) {
                return SizedBox(
                  height: 20,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: NeuButton(
              onPressed: () async {
                if (selectedFiles.length > 0) {
                  var res = await Api.downloadCreate(widget.listId[0], widget.destination, selectedFiles);
                  if (res['success']) {
                    Util.toast("下载任务创建成功");
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                } else {
                  Util.toast("请选择要下载的文件");
                }
              },
              // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              child: Text(
                "开始下载",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
