import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
// import 'package:tobias/tobias.dart';

class Full extends StatefulWidget {
  @override
  _FullState createState() => _FullState();
}

class _FullState extends State<Full> {
  bool isAlipayInstalled = false;
  int payType = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("解锁完整版"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Center(
            child: Text("解锁完整版，体验全部功能"),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "￥", style: TextStyle(fontSize: 24)),
                  TextSpan(
                    text: "9.9",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {},
            child: NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              curveType: payType == 0 ? CurveType.emboss : CurveType.flat,
              bevel: 12,
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Text("支付宝"),
                  Spacer(),
                  if (payType == 0)
                    Icon(
                      CupertinoIcons.checkmark_alt,
                      color: Color(0xffff9813),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          NeuButton(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () async {
              var res = await Api.payment();
              if (res['code'] == 1) {
                print(res['data']);
                // aliPay(res['data']);
              }
            },
            child: Text(
              ' 立即解锁 ',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
