import 'dart:convert';
import 'dart:typed_data';

import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';

class OtpBind extends StatefulWidget {
  final String username;
  final String email;
  OtpBind(this.username, this.email);
  @override
  _OtpBindState createState() => _OtpBindState();
}

class _OtpBindState extends State<OtpBind> {
  TextEditingController _emailController = TextEditingController();
  String email;
  int step = 0;
  Uint8List qrData;
  String key = "";
  String code = "";
  bool emailSaving = false;
  bool codeChecking = false;
  @override
  void initState() {
    setState(() {
      email = widget.email ?? "";
    });
    _emailController.value = TextEditingValue(text: email);
    super.initState();
  }

  getData() async {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("二步验证"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          if (step == 0) ...[
            Text("请输入电子邮件地址。如果您的移动设备遗失，可将紧急验证代码发送到在此提供的电子邮件地址。"),
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
                controller: _emailController,
                onChanged: (v) => email = v,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '电子邮件',
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
                if (email.isBlank) {
                  Util.toast("请输入邮箱");
                  return;
                }
                if (emailSaving) {
                  return;
                }
                setState(() {
                  emailSaving = true;
                });
                var res = await Api.saveMail(email);

                if (res['success']) {
                  var qrcode = await Api.getQrCode("${widget.username}@${Util.hostname}");
                  if (qrcode['success']) {
                    setState(() {
                      qrData = Base64Decoder().convert(qrcode['data']['img']);
                      key = qrcode['data']['key'];
                      step = 1;
                    });
                  } else {
                    Util.toast("获取二部验证数据出错，代码${res['error']['code']}");
                  }
                } else {
                  Util.toast("保存邮箱出错，代码${res['error']['code']}");
                }
                setState(() {
                  emailSaving = false;
                });
              },
              child: emailSaving
                  ? CupertinoActivityIndicator(
                      radius: 13,
                    )
                  : Text(
                      ' 下一步 ',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ] else if (step == 1) ...[
            Text("DSM 支持以下验证器应用程序： Google Authenticator, Authy等，打开验证器，扫描以下二维码，或者手动输入秘钥"),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Image.memory(qrData),
            ),
            SizedBox(
              height: 20,
            ),
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              curveType: CurveType.flat,
              bevel: 20,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "账号：${widget.username}@${Util.hostname}",
                      ),
                    ),
                    NeuButton(
                      onPressed: () async {
                        ClipboardData data = new ClipboardData(text: "${widget.username}@${Util.hostname}");
                        Clipboard.setData(data);
                        Util.toast("已复制到剪贴板");
                      },
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(5),
                      bevel: 5,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(
                          Icons.copy,
                          color: Color(0xffff9813),
                          size: 16,
                        ),
                      ),
                    ),
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
              curveType: CurveType.flat,
              bevel: 20,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "秘钥：$key",
                      ),
                    ),
                    NeuButton(
                      onPressed: () async {
                        ClipboardData data = new ClipboardData(text: "$key");
                        Clipboard.setData(data);
                        Util.toast("已复制到剪贴板");
                      },
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(5),
                      bevel: 5,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(
                          Icons.copy,
                          color: Color(0xffff9813),
                          size: 16,
                        ),
                      ),
                    ),
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
              bevel: 12,
              curveType: CurveType.flat,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: NeuTextField(
                onChanged: (v) => code = v,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '6位验证代码',
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
                if (code.isBlank) {
                  Util.toast("请输入6位验证代码");
                  return;
                }
                if (codeChecking) {
                  return;
                }
                setState(() {
                  codeChecking = true;
                });
                var res = await Api.authOtpCode(code);

                if (res['success']) {
                  setState(() {
                    step = 2;
                  });
                } else {
                  Util.toast("保存邮箱出错，代码${res['error']['code']}");
                }
                setState(() {
                  emailSaving = false;
                });
              },
              child: codeChecking
                  ? CupertinoActivityIndicator(
                      radius: 13,
                    )
                  : Text(
                      ' 下一步 ',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ] else if (step == 2) ...[
            Text("两步骤验证设置完成。下次登录 DSM 时，将提示您输入验证器应用程序生成的验证代码。两步骤验证对于用某些移动应用程序进行登录有影响。为避免遇到任何难题，请确认您已安装任何需要登录 DSM 的移动应用程序的最新版本。"),
            Text("注意：您可在“帐户活动” &gt; “记住的设备”中管理最常用的设备。"),
            NeuButton(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text(
                ' 完成 ',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
