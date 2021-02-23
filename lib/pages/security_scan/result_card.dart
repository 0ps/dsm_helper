import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/strings.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ResultCard extends StatelessWidget {
  final Map data;
  ResultCard(this.data);
  final Map colors = {
    "safe": Colors.green,
    "risk": Colors.red,
    "warning": Colors.orange,
    "info": Colors.orangeAccent,
    "outOfDate": Colors.amber,
  };
  final Map icons = {
    "safe": Icons.check_circle,
    "risk": Icons.info,
    "warning": Icons.info,
    "info": Icons.info,
    "outOfDate": Icons.info,
  };
  List<Widget> _buildFailItems() {
    List<Widget> items = [];
    data['fail'].forEach((k, v) {
      if (v > 0) {
        items.add(Text(
          "${(webManagerStrings['securityscan']['securityscan_check_${k}_${data['category']}'] ?? Util.strings['SYNO.SDS.SecurityScan.Instance']['securityscan']["securityscan_check_${k}_${data['category']}"]).replaceAll("{0}", "${data['fail'][k]}")}",
          style: TextStyle(color: colors[k]),
        ));
      }
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(bottom: 20),
      curveType: CurveType.flat,
      bevel: 20,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${webManagerStrings['securityscan']['securityscan_category_${data['category']}'] ?? Util.strings['SYNO.SDS.SecurityScan.Instance']['securityscan']['securityscan_category_${data['category']}']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                if (data['progress'] == 100)
                  Icon(
                    icons[data['failSeverity']],
                    color: colors[data['failSeverity']],
                    size: 30,
                  )
                else
                  CircularPercentIndicator(
                    radius: 30,
                    // progressColor: Colors.lightBlueAccent,
                    animation: true,
                    linearGradient: LinearGradient(
                      colors: data['progress'] < 90
                          ? [
                              Colors.blue,
                              Colors.blueAccent,
                            ]
                          : [
                              Colors.green,
                              Colors.greenAccent,
                            ],
                    ),
                    animateFromLastPercent: true,
                    circularStrokeCap: CircularStrokeCap.round,
                    lineWidth: 5,
                    backgroundColor: Colors.black12,
                    percent: data['progress'] / 100,
                    center: Text(
                      "${data['progress']}%",
                      style: TextStyle(color: data['progress'] < 90 ? Colors.blue : Colors.red, fontSize: 8),
                    ),
                  )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            if (data['progress'] == 100)
              if (data['failSeverity'] == "safe")
                Text(
                  "${webManagerStrings['securityscan']['securityscan_check_pass_${data['category']}'] ?? Util.strings['SYNO.SDS.SecurityScan.Instance']['securityscan']["securityscan_check_pass_${data['category']}"]}",
                  style: TextStyle(color: Colors.green),
                )
              else
                ..._buildFailItems()
            else ...[
              Text(
                "${webManagerStrings['securityscan']['securityscan_check_desc_${data['category']}'] ?? Util.strings['SYNO.SDS.SecurityScan.Instance']['securityscan']["securityscan_check_desc_${data['category']}"]}",
                style: TextStyle(color: Colors.blue),
              ),
              Text(
                "${webManagerStrings['rules']["${data['runningItem']}_desc_running"] ?? Util.strings['SYNO.SDS.SecurityScan.Instance']['rules']["${data['runningItem']}_desc_running"]}",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
