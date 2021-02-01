import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class ConfirmLogout extends StatefulWidget {
  final bool otpEnable;
  ConfirmLogout(this.otpEnable);
  @override
  _ConfirmLogoutState createState() => _ConfirmLogoutState();
}

class _ConfirmLogoutState extends State<ConfirmLogout> {
  bool forget = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: NeuCard(
        width: double.infinity,
        bevel: 5,
        curveType: CurveType.emboss,
        decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "注销登录",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                "确认要注销登录吗？",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 22,
              ),
              if (widget.otpEnable) ...[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      forget = !forget;
                    });
                  },
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: forget ? CurveType.emboss : CurveType.flat,
                    bevel: 12,
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        Text("取消记住本设备"),
                        Spacer(),
                        if (forget)
                          Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Color(0xffff9813),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      onPressed: () async {
                        if (forget) {
                          Api.trustDevice("delete");
                        }
                        Util.removeStorage("sid");
                        // Util.removeStorage("smid");
                        Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                      },
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      bevel: 5,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "注销登录",
                        style: TextStyle(fontSize: 18, color: Colors.redAccent),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
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
      ),
    );
  }
}
