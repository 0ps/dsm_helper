import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ExternalDevice extends StatefulWidget {
  @override
  _ExternalDeviceState createState() => _ExternalDeviceState();
}

class _ExternalDeviceState extends State<ExternalDevice> {
  List esatas = [];
  bool loading = true;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.externalDevice();
    if (res['success']) {
      setState(() {
        loading = false;
      });
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.Core.ExternalDevice.Storage.eSATA":
              setState(() {
                esatas = item['data']['devices'];
              });
          }
        }
      });
    } else {
      Util.toast("获取外接设备失败，code${res['error']['code']}");
    }
  }

  Widget _buildPartitionItem(partition) {
    return NeuCard(
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(top: 20),
      bevel: 20,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("${partition['partition_title']}"),
              SizedBox(
                width: 10,
              ),
              partition['status'] == "normal"
                  ? Label(
                      "正常",
                      Colors.green,
                      fill: true,
                    )
                  : partition['status'] == "background"
                      ? Label(
                          "正在检查硬盘",
                          Colors.lightBlueAccent,
                          fill: true,
                        )
                      : Label(
                          partition['status'],
                          Colors.red,
                          fill: true,
                        ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
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
                    colors: partition['used_size_mb'] / partition['total_size_mb'] <= 0.9
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
                  percent: partition['used_size_mb'] / partition['total_size_mb'],
                  center: Text(
                    "${(partition['used_size_mb'] / partition['total_size_mb'] * 100).toStringAsFixed(0)}%",
                    style: TextStyle(color: partition['used_size_mb'] / partition['total_size_mb'] <= 0.9 ? Colors.blue : Colors.red, fontSize: 22),
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
                          "${partition['share_name']}",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Label(
                          partition['filesystem'] ?? partition['dev_fstype'],
                          Colors.blue,
                          fill: true,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("已用：${Util.formatSize(partition['used_size_mb'] * 1024 * 1024)}"),
                    SizedBox(
                      height: 5,
                    ),
                    Text("可用：${Util.formatSize(partition['total_size_mb'] * 1024 * 1024 - partition['used_size_mb'] * 1024 * 1024)}"),
                    SizedBox(
                      height: 5,
                    ),
                    Text("容量：${Util.formatSize(partition['total_size_mb'] * 1024 * 1024)}"),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildESataItem(esata) {
    List partitions = esata['partitions'];
    return NeuCard(
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${esata['dev_title']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 10,
                ),
                esata['status'] == "normal"
                    ? Label(
                        "正常",
                        Colors.green,
                        fill: true,
                      )
                    : Label(
                        esata['status'],
                        Colors.red,
                        fill: true,
                      ),
                SizedBox(
                  width: 10,
                ),
                Spacer(),
                NeuButton(
                  onPressed: () async {
                    var res = await Api.ejectEsata(esata['dev_id']);
                    if (res['success']) {
                      Util.toast("设备已退出");
                      getData();
                    } else {
                      Util.toast("设备退出失败，代码${res['error']['code']}");
                    }
                  },
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(5),
                  bevel: 5,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Icon(
                      CupertinoIcons.eject,
                      color: Color(0xffff9813),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            ...partitions.map(_buildPartitionItem).toList(),
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
        title: Text("外接设备"),
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
          : ListView.separated(
              padding: EdgeInsets.all(20),
              itemBuilder: (context, i) {
                return _buildESataItem(esatas[i]);
              },
              separatorBuilder: (context, i) {
                return SizedBox(
                  height: 20,
                );
              },
              itemCount: esatas.length),
    );
  }
}
