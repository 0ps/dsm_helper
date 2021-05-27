import 'package:cool_ui/cool_ui.dart';
import 'package:dsm_helper/util/api.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/neu_picker.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

class EditDdns extends StatefulWidget {
  final Map ddns;
  final List extIp;
  final List providers;
  const EditDdns(this.providers, {this.extIp: const [], this.ddns, Key key}) : super(key: key);

  @override
  _EditDdnsState createState() => _EditDdnsState();
}

class _EditDdnsState extends State<EditDdns> {
  TextEditingController _hostnameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  Map ddns = {};
  Map statusStr = {
    "service_ddns_normal": "正常",
    "service_ddns_error_unknown": "联机失败",
    "loading": "加载中",
    "disabled": "已停用",
  };
  @override
  void initState() {
    if (widget.ddns != null) {
      setState(() {
        ddns.addAll(widget.ddns);
      });
      _hostnameController.value = TextEditingValue(text: ddns['hostname']);
      _usernameController.value = TextEditingValue(text: ddns['username']);
    } else {
      ddns = {"enable": true, "heartbeat": false, "net": "DEFAULT", "ip": "-", "ipv6": "-"};
      if (widget.extIp.length > 0) {
        ddns['ip'] = widget.extIp.first['ip'];
        ddns['ipv6'] = widget.extIp.first['ipv6'];
      }
    }
    if (ddns['ip'] == "0.0.0.0") {
      ddns["ip"] = "-";
    }
    if (ddns['ipv6'] == "0:0:0:0:0:0:0:0") {
      ddns['ipv6'] = "-";
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

  bool checkForm() {
    if (ddns['provider'] == null || ddns['provider'] == "") {
      Util.toast("请选择服务供应商");
      return false;
    } else if (ddns['hostname'] == null || ddns['hostname'] == "") {
      Util.toast("请输入主机名称");
      return false;
    } else if (ddns['username'] == null || ddns['username'] == "") {
      Util.toast("请输入用户名/电子邮件");
      return false;
    } else if (widget.ddns == null && (ddns['passwd'] == null || ddns['passwd'] == "")) {
      Util.toast("请输入密码/密钥");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("DDNS"),
        actions: [
          if (widget.ddns != null)
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
                if (widget.ddns != null) ...[
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
                ],
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
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
                              print(ddns['provider']);
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
                        Text("${ddns['provider'] != null && ddns['provider'] != "" ? widget.providers.where((element) => element['provider'] == ddns['provider']).first['provider'] : "请选择"}"),
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
                ),
                //statusStr[ddns['status']] ?? ddns['status']
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: NeuCard(
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(20),
                        bevel: 20,
                        curveType: CurveType.flat,
                        child: Row(
                          children: [
                            Text("状态:"),
                            SizedBox(
                              width: 10,
                            ),
                            if (ddns['status'] != null)
                              Label(
                                statusStr[ddns['status']] ?? ddns['status'],
                                ddns['status'] == "service_ddns_normal" ? Colors.green : Colors.red,
                                fill: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    NeuButton(
                      onPressed: () async {
                        if (checkForm()) {
                          var hide = showWeuiLoadingToast(context: context, message: Text("测试中，请稍后"), backButtonClose: true, alignment: Alignment.center);
                          var res = await Api.ddnsTest(ddns);
                          hide();
                          print(res);
                          if (res['success']) {
                            setState(() {
                              ddns['status'] = res['data']['status'];
                            });
                          } else {
                            Util.toast("测试失败，${res['error']['errors']},code:${res['error']['code']}");
                          }
                        }
                      },
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(20),
                      bevel: 20,
                      child: Text("测试联机"),
                    ),
                  ],
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
              onPressed: () async {
                if (checkForm()) {
                  var res = await Api.ddnsSave(ddns);
                  if (res['success']) {
                    Util.toast("保存成功");
                    Navigator.of(context).pop(true);
                  } else {
                    Util.toast("保存失败,代码${res['error']['code']}");
                  }
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
