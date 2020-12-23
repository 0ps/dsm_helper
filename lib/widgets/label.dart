/*
 * 创建日期：23/12/19 下午 05:31
 * 版权所有：青岛人才在线企业服务管理有限公司
 */

import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  Label(this.name, this.color, {this.fill: false, this.fontSize});
  final String name;
  final Color color;
  final bool fill;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: fill ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Text(
        name,
        style: TextStyle(color: fill ? Colors.white : color, fontSize: fontSize ?? 12),
      ),
    );
  }
}
