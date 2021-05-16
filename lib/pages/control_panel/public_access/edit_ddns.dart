import 'package:dsm_helper/util/api.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/neu_picker.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

class EditDdns extends StatefulWidget {
  final Map ddns;
  final List providers;
  const EditDdns(this.providers, {this.ddns, Key key}) : super(key: key);

  @override
  _EditDdnsState createState() => _EditDdnsState();
}

class _EditDdnsState extends State<EditDdns> {
  TextEditingController _hostnameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  Map ddns = {};
  @override
  void initState() {
    if (widget.ddns != null) {
      setState(() {
        ddns.addAll(widget.ddns);
      });
      _hostnameController.value = TextEditingValue(text: ddns['hostname']);
      _usernameController.value = TextEditingValue(text: ddns['username']);
    }

    super.initState();
  }

  deleteDdns() async {
    Util.vibrate(FeedbackType.warning);
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
                  "确认删除",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "确认要删除以下DDNS？",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 22,
                ),
                Row(
                  children: [
                    Expanded(
                      child: NeuButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          var res = await Api.ddnsDelete(widget.ddns['id']);
                          print(res);
                          if (res['success']) {
                            Util.toast("DDNS删除成功");
                            Navigator.of(context).pop(true);
                          } else {
                            Util.toast("删除失败，代码:${res['error']['code']}");
                          }
                        },
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        bevel: 5,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "确认删除",
                          style: TextStyle(fontSize: 18, color: Colors.redAccent),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: NeuButton(
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
                    ),
                  ],
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("DDNS"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: NeuButton(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              bevel: 5,
              onPressed: deleteDdns,
              child: Image.asset(
                "assets/icons/delete.png",
                width: 30,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      ddns['enable'] = !ddns['enable'];
                    });
                  },
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(20),
                    bevel: 20,
                    curveType: ddns['enable'] ? CurveType.emboss : CurveType.flat,
                    child: Row(
                      children: [
                        Text("启用支持DDNS"),
                        Spacer(),
                        if (ddns['enable'])
                          Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Color(0xffff9813),
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.ddns != null) {
                      return;
                    }
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return NeuPicker(
                          widget.providers.map((e) => e['provider']).toList(),
                          value: widget.providers.indexWhere((element) => element['provider'] == ddns['provider']),
                          onConfirm: (v) {
                            setState(() {
                              ddns['provider'] = widget.providers[v]['provider'];
                            });
                          },
                        );
                      },
                    );
                  },
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(20),
                    bevel: 20,
                    curveType: widget.ddns == null ? CurveType.flat : CurveType.convex,
                    child: Row(
                      children: [
                        Text("服务供应商"),
                        Spacer(),
                        Text("${widget.providers.where((element) => element['provider'] == ddns['provider']).first['provider']}"),
                      ],
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
                    controller: _hostnameController,
                    onChanged: (v) => ddns['hostname'] = v,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '主机名称',
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
                    controller: _usernameController,
                    onChanged: (v) => ddns['username'] = v,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '用户名/电子邮件',
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
                    onChanged: (v) => ddns['passwd'] = v,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '密码/密钥',
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
                  padding: EdgeInsets.all(20),
                  bevel: 20,
                  curveType: CurveType.flat,
                  child: Row(
                    children: [
                      Text("外部地址(ipv4):"),
                      Spacer(),
                      Text("${ddns['ip']}"),
                    ],
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
                  padding: EdgeInsets.all(20),
                  bevel: 20,
                  curveType: CurveType.flat,
                  child: Row(
                    children: [
                      Text("外部地址(ipv6):"),
                      Spacer(),
                      Text("${ddns['ipv6']}"),
                    ],
                  ),
                )
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
              onPressed: () async {
                var res = await Api.ddnsSave(ddns);
                if (res['success']) {
                  Util.toast("保存成功");
                  Navigator.of(context).pop(true);
                } else {
                  Util.toast("保存失败,代码${res['error']['code']}");
                }
              },
              child: Text(
                ' 保存 ',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
