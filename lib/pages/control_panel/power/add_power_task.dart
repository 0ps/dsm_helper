import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:neumorphic/neumorphic.dart';

class AddPowerTask extends StatefulWidget {
  final String title;
  final Map task;
  AddPowerTask(this.title, {this.task});
  @override
  _AddPowerTaskState createState() => _AddPowerTaskState();
}

class _AddPowerTaskState extends State<AddPowerTask> {
  Map task = {
    "enabled": true,
    "hour": 0,
    "min": 0,
    "weekdays": "0,1,2,3,4,5,6",
    "type": "power_on",
  };
  List<String> weekdays = ["0", "1", "2", "3", "4", "5", "6"];

  @override
  void initState() {
    if (widget.task != null) {
      setState(() {
        task = widget.task;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          NeuCard(
            curveType: CurveType.flat,
            bevel: 20,
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "类型",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              task['type'] = "power_on";
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: task['type'] == "power_on" ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Text("开机"),
                                Spacer(),
                                if (task['type'] == "power_on")
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              task['type'] = "power_off";
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: task['type'] == "power_off" ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text("关机"),
                                Spacer(),
                                if (task['type'] == "power_off")
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          NeuCard(
            curveType: CurveType.flat,
            bevel: 20,
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "星期",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (weekdays.contains("0")) {
                                weekdays.remove("0");
                              } else {
                                weekdays.add("0");
                              }
                              weekdays.sort((a, b) {
                                return a.compareTo(b);
                              });
                              task['weekdays'] = weekdays.join(",");
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: weekdays.contains("0") ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text("日"),
                                Spacer(),
                                if (weekdays.contains("0"))
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (weekdays.contains("1")) {
                                weekdays.remove("1");
                              } else {
                                weekdays.add("1");
                              }
                              weekdays.sort((a, b) {
                                return a.compareTo(b);
                              });
                              task['weekdays'] = weekdays.join(",");
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: weekdays.contains("1") ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text("一"),
                                Spacer(),
                                if (weekdays.contains("1"))
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (weekdays.contains("2")) {
                                weekdays.remove("2");
                              } else {
                                weekdays.add("2");
                              }
                              weekdays.sort((a, b) {
                                return a.compareTo(b);
                              });
                              task['weekdays'] = weekdays.join(",");
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: weekdays.contains("2") ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text("二"),
                                Spacer(),
                                if (weekdays.contains("2"))
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (weekdays.contains("3")) {
                                weekdays.remove("3");
                              } else {
                                weekdays.add("3");
                              }
                              weekdays.sort((a, b) {
                                return a.compareTo(b);
                              });
                              task['weekdays'] = weekdays.join(",");
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: weekdays.contains("3") ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text("三"),
                                Spacer(),
                                if (weekdays.contains("3"))
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (weekdays.contains("4")) {
                                weekdays.remove("4");
                              } else {
                                weekdays.add("4");
                              }
                              weekdays.sort((a, b) {
                                return a.compareTo(b);
                              });
                              task['weekdays'] = weekdays.join(",");
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: weekdays.contains("4") ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text("四"),
                                Spacer(),
                                if (weekdays.contains("4"))
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (weekdays.contains("5")) {
                                weekdays.remove("5");
                              } else {
                                weekdays.add("5");
                              }
                              weekdays.sort((a, b) {
                                return a.compareTo(b);
                              });
                              task['weekdays'] = weekdays.join(",");
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: weekdays.contains("5") ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text("五"),
                                Spacer(),
                                if (weekdays.contains("5"))
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (weekdays.contains("6")) {
                                weekdays.remove("6");
                              } else {
                                weekdays.add("6");
                              }
                              weekdays.sort((a, b) {
                                return a.compareTo(b);
                              });
                              task['weekdays'] = weekdays.join(",");
                            });
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: weekdays.contains("6") ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text("六"),
                                Spacer(),
                                if (weekdays.contains("6"))
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xffff9813),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(flex: 1, child: Container()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          NeuCard(
            curveType: CurveType.flat,
            bevel: 20,
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "时间",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            DatePicker.showTimePicker(
                              context,
                              currentTime: DateTime(2021, 01, 01, task['hour'], task['min']),
                              showSecondsColumn: false,
                              onConfirm: (time) {
                                setState(() {
                                  task['hour'] = time.hour;
                                  task['min'] = time.minute;
                                });
                              },
                              locale: LocaleType.zh,
                            );
                          },
                          child: NeuCard(
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            curveType: task['type'] == "power_on" ? CurveType.emboss : CurveType.flat,
                            bevel: 12,
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Text("${task['hour'].toString().padLeft(2, "0")}:${task['min'].toString().padLeft(2, "0")}"),
                                Spacer(),
                                Icon(
                                  CupertinoIcons.right_chevron,
                                  color: Color(0xffff9813),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
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
            onPressed: () {
              Navigator.of(context).pop(task);
            },
            child: Text(
              ' 确定 ',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
