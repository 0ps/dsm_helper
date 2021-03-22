import 'package:dsm_helper/pages/control_panel/power/add_power_task.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

class Power extends StatefulWidget {
  @override
  _PowerState createState() => _PowerState();
}

class _PowerState extends State<Power> with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool loading = true;
  bool enableZram = false;
  Map powerRecovery;
  Map beepControl;
  Map fanSpeed;
  Map hibernation;
  Map ups;
  List powerTasks = [];
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    Api.powerStatus().then((res) {
      if (res['success']) {
        setState(() {
          loading = false;
        });
        List result = res['data']['result'];
        result.forEach((item) {
          print(item['data']);
          if (item['success'] == true) {
            switch (item['api']) {
              case "SYNO.Core.Hardware.ZRAM":
                setState(() {
                  enableZram = item['data']['enable_zram'];
                });
                break;
              case "SYNO.Core.Hardware.PowerRecovery":
                setState(() {
                  powerRecovery = item['data'];
                });
                break;
              case "SYNO.Core.Hardware.BeepControl":
                setState(() {
                  beepControl = item['data'];
                });
                break;
              case "SYNO.Core.Hardware.FanSpeed":
                setState(() {
                  fanSpeed = item['data'];
                });
                break;
              case "SYNO.Core.ExternalDevice.UPS":
                setState(() {
                  ups = item['data'];
                });
                break;
              case "SYNO.Core.Hardware.PowerSchedule":
                setState(() {
                  List powerOnTasks = item['data']['poweron_tasks'];
                  List powerOffTasks = item['data']['poweroff_tasks'];
                  powerTasks = powerOnTasks.map((e) {
                        e['type'] = "power_on";
                        return e;
                      }).toList() +
                      powerOffTasks.map((e) {
                        e['type'] = "power_off";
                        return e;
                      }).toList();
                  powerTasks.sort((a, b) {
                    print(a);
                    if (a['hour'] > b['hour']) {
                      return 1;
                    } else if (a['hour'] == b['hour']) {
                      if (a['min'] > b['min']) {
                        return 1;
                      } else if (a['min'] < b['min']) {
                        return -1;
                      } else {
                        return 0;
                      }
                    } else {
                      return -1;
                    }
                  });
                });
            }
          }
        });
      }
    });
  }

  Map weekday = {
    "0": "周日",
    "1": "周一",
    "2": "周二",
    "3": "周三",
    "4": "周四",
    "5": "周五",
    "6": "周六",
  };
  Widget _buildPowerTaskItem(task) {
    String weekdays = "";
    if (task['weekdays'] == "0,1,2,3,4,5,6") {
      weekdays = "每天";
    } else if (task['weekdays'] == "1,2,3,4,5") {
      weekdays = "平日";
    } else if (task['weekdays'] == "0,6") {
      weekdays = "假日";
    } else {
      List days = task['weekdays'].split(",");
      weekdays = days.map((e) => weekday[e]).join(",");
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          task['enabled'] = !task['enabled'];
        });
      },
      child: NeuCard(
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        bevel: 10,
        curveType: task['enabled'] ? CurveType.emboss : CurveType.flat,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: task['enabled']
                    ? Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Color(0xffff9813),
                        size: 22,
                      )
                    : null,
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("${task['hour'].toString().padLeft(2, "0")}:${task['min'].toString().padLeft(2, "0")}"),
                        SizedBox(
                          width: 5,
                        ),
                        Label(task['type'] == "power_on" ? "开机" : "关机", task['type'] == "power_on" ? Colors.green : Colors.orangeAccent),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "$weekdays",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  NeuButton(
                    onPressed: () {
                      setState(() {
                        powerTasks.remove(task);
                      });
                    },
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(5),
                    bevel: 5,
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  NeuButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(
                              builder: (context) {
                                return AddPowerTask(
                                  "编辑计划管理",
                                  task: task,
                                );
                              },
                              settings: RouteSettings(name: "edit_power_task")))
                          .then((value) {
                        if (value != null) {
                          for (var item in powerTasks) {
                            if (item != task && item['hour'] == value['hour'] && item['min'] == value['min']) {
                              Util.toast("无效或重复规则");
                              Util.vibrate(FeedbackType.warning);
                              return;
                            }
                          }
                          setState(() {
                            task = value;
                          });
                        }
                      });
                    },
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(5),
                    bevel: 5,
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("硬件和电源"),
      ),
      body: loading
          ? Center(
              child: NeuCard(
                padding: EdgeInsets.all(50),
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: CupertinoActivityIndicator(
                  radius: 14,
                ),
              ),
            )
          : Column(
              children: [
                NeuCard(
                  width: double.infinity,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  curveType: CurveType.flat,
                  bevel: 10,
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicator: BubbleTabIndicator(
                      indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                      shadowColor: Util.getAdjustColor(Theme.of(context).scaffoldBackgroundColor, -20),
                    ),
                    tabs: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("常规"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("开关机计划管理"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("硬盘休眠"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("不断电系统"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "内存压缩",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  enableZram = !enableZram;
                                                });
                                              },
                                              child: NeuCard(
                                                decoration: NeumorphicDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.all(10),
                                                bevel: 10,
                                                curveType: enableZram ? CurveType.emboss : CurveType.flat,
                                                child: Row(
                                                  children: [
                                                    Text("启用内存压缩可提高系统响应性能"),
                                                    Spacer(),
                                                    if (enableZram)
                                                      Icon(
                                                        CupertinoIcons.checkmark_alt,
                                                        color: Color(0xffff9813),
                                                        size: 22,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "电源自动恢复",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  powerRecovery['rc_power_config'] = !powerRecovery['rc_power_config'];
                                                });
                                              },
                                              child: NeuCard(
                                                decoration: NeumorphicDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.all(10),
                                                bevel: 10,
                                                curveType: powerRecovery['rc_power_config'] ? CurveType.emboss : CurveType.flat,
                                                child: Row(
                                                  children: [
                                                    Text("修复电源问题后自动重新启动"),
                                                    Spacer(),
                                                    if (powerRecovery['rc_power_config'])
                                                      Icon(
                                                        CupertinoIcons.checkmark_alt,
                                                        color: Color(0xffff9813),
                                                        size: 22,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (powerRecovery['wol1'] != null) ...[
                                              SizedBox(
                                                height: 20,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    powerRecovery['wol1'] = !powerRecovery['wol1'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: powerRecovery['wol1'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("启用局域网 ${powerRecovery['internal_lan_num']} 的局域网唤醒"),
                                                      Spacer(),
                                                      if (powerRecovery['wol1'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "哔声控制",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (beepControl['support_fan_fail']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['fan_fail'] = !beepControl['fan_fail'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['fan_fail'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("冷却风扇故障"),
                                                      Spacer(),
                                                      if (beepControl['fan_fail'])
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
                                            if (beepControl['support_volume_crash']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['volume_crash'] = !beepControl['volume_crash'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['volume_crash'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("存储空间降级或毁损"),
                                                      Spacer(),
                                                      if (beepControl['volume_crash'])
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
                                            if (beepControl['support_ssd_cache_crash']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['ssd_cache_crash'] = !beepControl['ssd_cache_crash'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['ssd_cache_crash'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("SSD 缓存异常"),
                                                      Spacer(),
                                                      if (beepControl['ssd_cache_crash'])
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
                                            if (beepControl['support_poweron_beep']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['poweron_beep'] = !beepControl['poweron_beep'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['poweron_beep'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("系统开机"),
                                                      Spacer(),
                                                      if (beepControl['poweron_beep'])
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
                                            if (beepControl['support_poweroff_beep']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['poweroff_beep'] = !beepControl['poweroff_beep'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['poweroff_beep'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("按下电源按钮后系统关机"),
                                                      Spacer(),
                                                      if (beepControl['poweroff_beep'])
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
                                            if (beepControl['support_redundant_power_fail']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['redundant_power_fail'] = !beepControl['redundant_power_fail'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['redundant_power_fail'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("冗余电源离线"),
                                                      Spacer(),
                                                      if (beepControl['redundant_power_fail'])
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
                                            if (beepControl['support_reset_beep']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['reset_beep'] = !beepControl['reset_beep'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['reset_beep'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("系统重置"),
                                                      Spacer(),
                                                      if (beepControl['reset_beep'])
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
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "风扇模式",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  fanSpeed['dual_fan_speed'] = "fullfan";
                                                });
                                              },
                                              child: NeuCard(
                                                decoration: NeumorphicDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.all(10),
                                                bevel: 10,
                                                curveType: fanSpeed['dual_fan_speed'] == "fullfan" ? CurveType.emboss : CurveType.flat,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("全速模式"),
                                                          Text(
                                                            "风扇以全速工作可保持系统冷却，但会产生较大的噪音。",
                                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 22,
                                                      child: fanSpeed['dual_fan_speed'] == "fullfan"
                                                          ? Icon(
                                                              CupertinoIcons.checkmark_alt,
                                                              color: Color(0xffff9813),
                                                              size: 22,
                                                            )
                                                          : null,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  fanSpeed['dual_fan_speed'] = "coolfan";
                                                });
                                              },
                                              child: NeuCard(
                                                decoration: NeumorphicDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.all(10),
                                                bevel: 10,
                                                curveType: fanSpeed['dual_fan_speed'] == "coolfan" ? CurveType.emboss : CurveType.flat,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("低温模式"),
                                                          Text(
                                                            "风扇以较高的速度工作可保持系统冷却，但会产生较大的噪音。",
                                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 22,
                                                      child: fanSpeed['dual_fan_speed'] == "coolfan"
                                                          ? Icon(
                                                              CupertinoIcons.checkmark_alt,
                                                              color: Color(0xffff9813),
                                                              size: 22,
                                                            )
                                                          : null,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  fanSpeed['dual_fan_speed'] = 'quietfan';
                                                });
                                              },
                                              child: NeuCard(
                                                decoration: NeumorphicDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.all(10),
                                                bevel: 10,
                                                curveType: fanSpeed['dual_fan_speed'] == 'quietfan' ? CurveType.emboss : CurveType.flat,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("静音模式"),
                                                          Text(
                                                            "风扇以较低的速度工作所产生的噪音较低，但过程中系统可能会变热。",
                                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 22,
                                                      child: fanSpeed['dual_fan_speed'] == 'quietfan'
                                                          ? Icon(
                                                              CupertinoIcons.checkmark_alt,
                                                              color: Color(0xffff9813),
                                                              size: 22,
                                                            )
                                                          : null,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
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
                                var res = await Api.powerSet(enableZram, powerRecovery, beepControl, fanSpeed);
                                if (res['success']) {
                                  if (res['data']['has_fail'] == false) {
                                    Util.vibrate(FeedbackType.light);
                                    Util.toast("保存成功");
                                  } else {
                                    Util.vibrate(FeedbackType.warning);
                                    Util.toast("设置未完全保存成功");
                                  }
                                  getData();
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
                      Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (context, i) {
                                return _buildPowerTaskItem(powerTasks[i]);
                              },
                              itemCount: powerTasks.length,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: NeuButton(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                              builder: (context) {
                                                return AddPowerTask(
                                                  "新增计划管理",
                                                );
                                              },
                                              settings: RouteSettings(name: "edit_power_task")))
                                          .then((value) {
                                        if (value != null) {
                                          for (var item in powerTasks) {
                                            if (item['hour'] == value['hour'] && item['min'] == value['min']) {
                                              Util.toast("无效或重复规则");
                                              Util.vibrate(FeedbackType.warning);
                                              return;
                                            }
                                          }
                                          setState(() {
                                            powerTasks.add(value);
                                          });
                                        }
                                      });
                                    },
                                    child: Text(
                                      ' 新增 ',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: NeuButton(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onPressed: () async {
                                      List powerOns = powerTasks.where((task) => task['type'] == "power_on").map((e) {
                                        e.remove("type");
                                        return e;
                                      }).toList();
                                      List powerOffs = powerTasks.where((task) => task['type'] == "power_off").map((e) {
                                        e.remove("type");
                                        return e;
                                      }).toList();
                                      var res = await Api.powerScheduleSave(powerOns, powerOffs);
                                      if (res['success']) {
                                        Util.toast("保存成功");
                                        getData();
                                      } else {
                                        Util.toast("保存失败,代码${res['error']['code']}");
                                      }
                                    },
                                    child: Text(
                                      ' 保存 ',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Text("待开发"),
                      ),
                      Center(
                        child: Text("待开发"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
