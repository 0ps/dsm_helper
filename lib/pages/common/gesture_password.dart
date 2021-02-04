import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';
import 'package:gesture_password/gesture_password.dart';
import 'package:gesture_password/mini_gesture_password.dart';
import 'package:vibrate/vibrate.dart';

class GesturePasswordPage extends StatefulWidget {
  GesturePasswordPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GesturePasswordPageState createState() => new _GesturePasswordPageState();
}

class _GesturePasswordPageState extends State<GesturePasswordPage> {
  GlobalKey<MiniGesturePasswordState> miniGesturePassword = new GlobalKey<MiniGesturePasswordState>();
  int step = 1;
  String newPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text('设置密码'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Text(
              step == 1 ? "请绘制图案" : "请再绘制一遍",
              style: TextStyle(fontSize: 26),
            ),
            SizedBox(
              height: 80,
            ),
            Center(
              child: GesturePassword(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.9,
                attribute: ItemAttribute(normalColor: Colors.grey, selectedColor: Colors.blue, lineStrokeWidth: 4),
                successCallback: (s) {
                  if (step == 1) {
                    Util.vibrate(FeedbackType.light);
                    setState(() {
                      newPassword = s;
                      step = 2;
                    });
                  } else if (step == 2) {
                    if (s == newPassword) {
                      Util.vibrate(FeedbackType.success);
                      Util.setStorage("gesture_password", s);
                      Navigator.of(context).pop(true);
                    } else {
                      Util.toast("两次图案不一致，请重新设置");
                      Util.vibrate(FeedbackType.warning);
                      setState(() {
                        step = 1;
                        newPassword = "";
                      });
                    }
                  }
                },
                failCallback: () {
                  Util.toast("至少连接4个点");
                  Util.vibrate(FeedbackType.warning);
                  miniGesturePassword.currentState?.setSelected('');
                },
                selectedCallback: (str) {
                  miniGesturePassword.currentState?.setSelected(str);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
