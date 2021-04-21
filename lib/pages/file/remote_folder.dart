import 'package:dsm_helper/pages/file/select_folder.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

class RemoteFolder extends StatefulWidget {
  @override
  _RemoteFolderState createState() => _RemoteFolderState();
}

class _RemoteFolderState extends State<RemoteFolder> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String serverIp = "";
  String mountPoint = "";
  bool autoMount = false;
  String account = "";
  String passwd = "";
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("装载远程文件夹"),
      ),
      body: Column(
        children: [
          NeuCard(
            width: double.infinity,
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            curveType: CurveType.flat,
            bevel: 10,
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              unselectedLabelColor: Colors.grey,
              indicator: BubbleTabIndicator(
                indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                shadowColor: Util.getAdjustColor(Theme.of(context).scaffoldBackgroundColor, -20),
              ),
              tabs: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("CIFS"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("NFS"),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 20,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        onChanged: (v) => serverIp = v,
                        decoration: InputDecoration(border: InputBorder.none, labelText: '远程文件夹', hintText: r"示例:\\192.168.1.1\share"),
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
                      bevel: 20,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        onChanged: (v) => account = v,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '账号',
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
                      bevel: 20,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        onChanged: (v) => passwd = v,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '密码',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    NeuButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return SelectFolder(
                              multi: false,
                            );
                          },
                        ).then((res) {
                          if (res != null && res.length == 1) {
                            setState(() {
                              mountPoint = res[0];
                            });
                          }
                        });
                      },
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "装载到",
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(
                                  height: 20,
                                  child: Text(
                                    mountPoint == "" ? "选择装载到文件夹" : mountPoint,
                                    style: TextStyle(fontSize: 16, color: mountPoint == "" ? Colors.grey : null),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          autoMount = !autoMount;
                        });
                      },
                      child: NeuCard(
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        curveType: autoMount ? CurveType.emboss : CurveType.flat,
                        bevel: 12,
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          children: [
                            Text("开机时自动装载"),
                            Spacer(),
                            if (autoMount)
                              Icon(
                                CupertinoIcons.checkmark_alt,
                                color: Color(0xffff9813),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    NeuButton(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () async {
                        if (mountPoint == "") {
                          Util.toast("请选择保存位置");
                          Util.vibrate(FeedbackType.impact);
                          return;
                        }
                        if (serverIp.trim() == "") {
                          Util.toast("请输入远程文件夹地址");
                          return;
                        }
                        var res = await Api.mountFolder(serverIp, account, passwd, mountPoint, autoMount);
                        if (res['success']) {
                          Util.toast("装载成功");
                          Util.vibrate(FeedbackType.light);
                        } else {
                          Util.vibrate(FeedbackType.warning);
                          if (res['error']['code'] == 436) {
                            Util.toast("远程文件夹地址有误");
                          } else {
                            Util.toast("装载失败，代码${res['error']['code']}");
                          }
                        }
                      },
                      child: Text(
                        ' 装载 ',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text("开发中"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
