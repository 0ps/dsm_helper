import 'package:dsm_helper/util/function.dart';
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

class _StorageManagerState extends State<StorageManager> {
  bool loading = true;
  List ssdCaches = [];
  List volumes = [];
  List disks = [];
  List storagePools = [];
  Map env;
  @override
  void initState() {
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
      });
    } else {
      Util.toast("获取存储空间信息失败，代码${res['error']['code']}");
      Navigator.of(context).pop();
    }
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
                Row(
                  children: [
                    Text(
                      "${volume['deploy_path'] != null ? volume['deploy_path'].toString().replaceFirst("volume_", "存储空间 ") : volume['id'].toString().replaceFirst("volume_", "存储空间 ")}",
                      style: TextStyle(fontWeight: FontWeight.w600),
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
                Text("容量：${Util.formatSize(int.parse(volume['size']['total']))}"),
              ],
            ),
          )
        ],
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
          : ListView(
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
                      ...storagePools.map(_buildPoolItem).toList(),
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
    );
  }
}
