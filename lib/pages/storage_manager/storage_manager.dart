import 'package:dsm_helper/pages/storage_manager/smart.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/dashed_decoration.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StorageManager extends StatefulWidget {
  @override
  _StorageManagerState createState() => _StorageManagerState();
}

class _StorageManagerState extends State<StorageManager> with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool loading = true;
  List ssdCaches = [];
  List volumes = [];
  List disks = [];
  List storagePools = [];
  List hotSpares = [];
  Map env;
  @override
  void initState() {
    _tabController = TabController(length: 6, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.storage();
    if (res['success']) {
      setState(() {
        loading = false;
        ssdCaches = res['data']['ssdCaches'];
        volumes = res['data']['volumes'];
        // print(volumes);
        disks = res['data']['disks'];
        storagePools = res['data']['storagePools'];
        env = res['data']['env'];
        hotSpares = res['data']['hotSpares'];
      });
    } else {
      Util.toast("获取存储空间信息失败，代码${res['error']['code']}");
      Navigator.of(context).pop();
    }
  }

  Widget _buildSSDCacheItem(volume) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      child: Row(
        children: [
          NeuCard(
            curveType: CurveType.flat,
            margin: EdgeInsets.all(10),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(80),
              // color: Colors.red,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5),
            bevel: 8,
            child: CircularPercentIndicator(
              radius: 80,
              // progressColor: Colors.lightBlueAccent,
              animation: true,
              linearGradient: LinearGradient(
                colors: int.parse(volume['size']['used']) / int.parse(volume['size']['total']) <= 0.9
                    ? [
                        Colors.blue,
                        Colors.blueAccent,
                      ]
                    : [
                        Colors.red,
                        Colors.orangeAccent,
                      ],
              ),
              animateFromLastPercent: true,
              circularStrokeCap: CircularStrokeCap.round,
              lineWidth: 12,
              backgroundColor: Colors.black12,
              percent: int.parse(volume['size']['used']) / int.parse(volume['size']['total']),
              center: Text(
                "${(int.parse(volume['size']['used']) / int.parse(volume['size']['total']) * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: int.parse(volume['size']['used']) / int.parse(volume['size']['total']) <= 0.9 ? Colors.blue : Colors.red, fontSize: 22),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "${volume['id'].toString().replaceFirst("ssd_", "SSD 缓存 ")}",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Label(
                      volume['status'] == "normal" ? "正常" : volume['status'],
                      volume['status'] == "normal" ? Colors.green : Colors.red,
                      fill: true,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text("已用：${Util.formatSize(int.parse(volume['size']['used']))}"),
                SizedBox(
                  height: 5,
                ),
                Text("可用：${Util.formatSize(int.parse(volume['size']['total']) - int.parse(volume['size']['used']))}"),
                SizedBox(
                  height: 5,
                ),
                Text("容量：${Util.formatSize(int.parse(volume['size']['total']))}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVolumeItem(volume) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      child: Row(
        children: [
          NeuCard(
            curveType: CurveType.flat,
            margin: EdgeInsets.all(10),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(80),
              // color: Colors.red,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5),
            bevel: 8,
            child: CircularPercentIndicator(
              radius: 80,
              // progressColor: Colors.lightBlueAccent,
              animation: true,
              linearGradient: LinearGradient(
                colors: int.parse(volume['size']['used']) / int.parse(volume['size']['total']) <= 0.9
                    ? [
                        Colors.blue,
                        Colors.blueAccent,
                      ]
                    : [
                        Colors.red,
                        Colors.orangeAccent,
                      ],
              ),
              animateFromLastPercent: true,
              circularStrokeCap: CircularStrokeCap.round,
              lineWidth: 12,
              backgroundColor: Colors.black12,
              percent: int.parse(volume['size']['used']) / int.parse(volume['size']['total']),
              center: Text(
                "${(int.parse(volume['size']['used']) / int.parse(volume['size']['total']) * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: int.parse(volume['size']['used']) / int.parse(volume['size']['total']) <= 0.9 ? Colors.blue : Colors.red, fontSize: 22),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${volume['deploy_path'] != null ? volume['deploy_path'].toString().replaceFirst("volume_", "存储空间 ") : volume['id'].toString().replaceFirst("volume_", "存储空间 ")}",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Label(
                      "${volume['fs_type']}",
                      Colors.lightBlueAccent,
                      height: 23,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    volume['status'] == "normal"
                        ? Label(
                            "正常",
                            Colors.green,
                            fill: true,
                          )
                        : volume['status'] == "background"
                            ? Label(
                                "正在检查硬盘",
                                Colors.lightBlueAccent,
                                fill: true,
                              )
                            : volume['status'] == "attention"
                                ? Label(
                                    "注意",
                                    Colors.orangeAccent,
                                    fill: true,
                                  )
                                : Label(
                                    volume['status'],
                                    Colors.red,
                                    fill: true,
                                  ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text("已用：${Util.formatSize(int.parse(volume['size']['used']))}"),
                SizedBox(
                  height: 5,
                ),
                Text("可用：${Util.formatSize(int.parse(volume['size']['total']) - int.parse(volume['size']['used']))}"),
                SizedBox(
                  height: 5,
                ),
                Text("全部：${Util.formatSize(int.parse(volume['size']['total']))}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDiskItem(disk, {bool full: false}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) {
              return Smart(disk);
            },
            settings: RouteSettings(name: "disk_smart")));
      },
      child: NeuCard(
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        curveType: CurveType.flat,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 10),
        bevel: 10,
        child: Column(
          children: [
            Row(
              children: [
                NeuCard(
                  curveType: CurveType.flat,
                  margin: EdgeInsets.all(10),
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    // color: Colors.red,
                  ),
                  bevel: 8,
                  child: Image.asset(
                    disk['isSsd'] ? "assets/icons/ssd.png" : "assets/icons/hdd.png",
                    width: 40,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${disk['longName']}",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Label(
                            disk['overview_status'] == "normal" ? "正常" : disk['overview_status'],
                            disk['overview_status'] == "normal" ? Colors.green : Colors.red,
                            fill: true,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Label(
                            "${disk['temp']}℃",
                            Colors.lightBlueAccent,
                            height: 23,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("${disk['vendor'].trim()} ${disk['model'].trim()}"),
                      SizedBox(
                        height: 5,
                      ),
                      Text("${Util.formatSize(int.parse(disk['size_total']))}"),
                    ],
                  ),
                )
              ],
            ),
            if (full) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "位置",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${disk['container']['str']}"),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "硬盘类型",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${disk['diskType']}"),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "存储池",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("存储池 ${storagePools.where((pool) => pool['id'] == disk['used_by']).toList()[0]['num_id']}"),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "硬盘分配状态",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          "${disk['portType'] == "normal" ? "正常" : disk['status']}",
                          style: TextStyle(color: disk['portType'] == "normal" ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "健康状态",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          "${disk['status'] == "normal" ? "正常" : disk['status']}",
                          style: TextStyle(color: disk['status'] == "normal" ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "预计寿命",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${disk['remain_life'] == -1 ? "-" : disk['remain_life']}"),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "坏扇区数量",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${disk['unc']}"),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "温度",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${disk['temp']} ℃"),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "序列号",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${disk['serial']}"),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "固件版本",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${disk['firm']}"),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            "4K原生硬盘",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${disk['is4Kn'] ? "是" : "否"}"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPoolDetail(pool) {
    return NeuCard(
      curveType: CurveType.flat,
      bevel: 20,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "存储池 ${pool['num_id']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 5,
                ),
                pool['status'] == "normal"
                    ? Label(
                        "正常",
                        Colors.green,
                        fill: true,
                      )
                    : pool['status'] == "background"
                        ? Label(
                            "正在检查硬盘",
                            Colors.lightBlueAccent,
                            fill: true,
                          )
                        : pool['status'] == "attention"
                            ? Label(
                                "注意",
                                Colors.orangeAccent,
                                fill: true,
                              )
                            : Label(
                                pool['status'],
                                Colors.red,
                                fill: true,
                              ),
                Spacer(),
                Text("${Util.formatSize(int.parse(pool['size']['used']))} / ${Util.formatSize(int.parse(pool['size']['total']))}"),
              ],
            ),
            Row(
              children: [
                Text(
                  pool['device_type'] == "basic"
                      ? "Basic"
                      : pool['device_type'] == "shr_without_disk_protect" || pool['device_type'] == "shr"
                          ? "Synology Hybrid RAID (SHR) "
                          : pool['device_type'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (pool['device_type'] == "basic" || pool['device_type'] == "shr_without_disk_protect")
                  Text(
                    "（无数据保护）",
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    "支持多个存储空间",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text("${pool['raidType'] == "single" ? "否" : "是"}")
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    "可用容量",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text("${Util.formatSize(int.parse(pool['size']['total']) - int.parse(pool['size']['used']))}"),
              ],
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
                      "硬盘信息",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    ...disks.where((e) => pool['disks'].contains(e['id'])).map(_buildDiskItem).toList(),
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
                      "可用Hot Spare硬盘",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text("${pool['spares'] == null || pool['spares'].length == 0 ? "系统中无备援配置" : "暂不支持显示，共${pool['spares'].length}块"}"),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      "存储分配",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ...volumes.where((e) => e['pool_path'] == pool['id']).map(_buildVolumeItem).toList(),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolItem(pool) {
    return NeuCard(
      curveType: CurveType.flat,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        // color: Colors.red,
      ),
      padding: EdgeInsets.symmetric(horizontal: 5),
      bevel: 8,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("存储池 ${pool['num_id']}"),
                SizedBox(
                  width: 10,
                ),
                pool['status'] == "normal"
                    ? Label(
                        "正常",
                        Colors.green,
                        fill: true,
                      )
                    : pool['status'] == "background"
                        ? Label(
                            "正在检查硬盘",
                            Colors.lightBlueAccent,
                            fill: true,
                          )
                        : pool['status'] == "attention"
                            ? Label(
                                "注意",
                                Colors.orangeAccent,
                                fill: true,
                              )
                            : Label(
                                pool['status'],
                                Colors.red,
                                fill: true,
                              ),
                Spacer(),
                Text(Util.formatSize(int.parse(pool['size']['total']))),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  pool['device_type'] == "basic"
                      ? "Basic"
                      : pool['device_type'] == "shr_without_disk_protect" || pool['device_type'] == "shr"
                          ? "Synology Hybrid RAID (SHR) "
                          : pool['device_type'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (pool['device_type'] == "basic" || pool['device_type'] == "shr_without_disk_protect")
                  Text(
                    "（无数据保护）",
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("存储空间管理员"),
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
                        child: Text("系统概况"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("存储空间"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("存储池"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("HDD/SSD"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("Hot Spare"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("SSD 缓存"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView(
                        children: [
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            curveType: CurveType.flat,
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "存储空间状态",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                ...volumes.reversed.map(_buildVolumeItem).toList(),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            curveType: CurveType.flat,
                            bevel: 20,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "存储池",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                ...storagePools.reversed.map(_buildPoolItem).toList(),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                                    "硬盘信息",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Wrap(
                                    runSpacing: 5,
                                    spacing: 5,
                                    children: [
                                      for (int i = 0; i < int.parse(env['bay_number']); i++)
                                        Container(
                                          height: 20,
                                          width: 40,
                                          decoration: DashedDecoration(
                                            color: disks.where((disk) => disk['num_id'] == i + 1).length > 0 ? Colors.blue : Colors.transparent,
                                            dashedColor: disks.where((disk) => disk['num_id'] == i + 1).length > 0 ? Colors.blue : Colors.grey,
                                            gap: disks.where((disk) => disk['num_id'] == i + 1).length > 0 ? 0.1 : 2,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      volumes.length > 0
                          ? ListView.separated(
                              itemBuilder: (context, i) {
                                return _buildVolumeItem(volumes.reversed.toList()[i]);
                              },
                              itemCount: volumes.length,
                              separatorBuilder: (context, i) {
                                return SizedBox(
                                  height: 20,
                                );
                              },
                            )
                          : Center(
                              child: Text("无存储空间"),
                            ),
                      storagePools.length > 0
                          ? ListView.separated(
                              padding: EdgeInsets.all(20),
                              itemBuilder: (context, i) {
                                return _buildPoolDetail(storagePools.reversed.toList()[i]);
                              },
                              itemCount: storagePools.length,
                              separatorBuilder: (context, i) {
                                return SizedBox(
                                  height: 20,
                                );
                              },
                            )
                          : Center(
                              child: Text("无存储池"),
                            ),
                      disks.length > 0
                          ? ListView.separated(
                              padding: EdgeInsets.all(20),
                              itemBuilder: (context, i) {
                                return _buildDiskItem(disks[i], full: true);
                              },
                              itemCount: disks.length,
                              separatorBuilder: (context, i) {
                                return SizedBox(
                                  height: 20,
                                );
                              },
                            )
                          : Center(
                              child: Text("无HDD/SSD"),
                            ),
                      Center(
                        child: Text("${hotSpares.length > 0 ? "暂不支持显示，共${hotSpares.length}个" : "无备援装置"}"),
                      ),
                      ssdCaches.length > 0
                          ? ListView.separated(
                              itemBuilder: (context, i) {
                                return _buildSSDCacheItem(ssdCaches[i]);
                              },
                              separatorBuilder: (context, i) {
                                return SizedBox(
                                  height: 20,
                                );
                              },
                              itemCount: ssdCaches.length)
                          : Center(
                              child: Text("无SSD缓存"),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
