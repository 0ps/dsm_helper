/*
 * 创建日期：23/12/19 下午 05:31
 * 版权所有：青岛人才在线企业服务管理有限公司
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Badge extends StatelessWidget {
  final dynamic badge;
  final double size;
  Badge(this.badge, {this.size: 44});
  @override
  Widget build(BuildContext context) {
    if ((badge is num && badge > 0) || (badge is String && badge != "")) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: size / 44 * 14),
        alignment: Alignment.center,
        height: size,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(size / 44 * 30), boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(1, 2)),
        ]),
        child: Text(
          "$badge",
          style: TextStyle(color: Colors.white, fontSize: size / 44 * 28),
        ),
      );
    } else {
      return Container();
    }
  }
}
