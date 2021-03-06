import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';
import 'add_tracker.dart';

class DownloadDetail extends StatefulWidget {
  final String id;
  DownloadDetail(this.id);
  @override
  _DownloadDetailState createState() => _DownloadDetailState();
}

class _DownloadDetailState extends State<DownloadDetail> with TickerProviderStateMixin {
  TabController _tabController;
  bool loading = true;
  bool loadingTrackers = true;
  bool loadingPeers = true;
  bool loadingFiles = true;
  List trackers = [];
  List peers = [];
  List files = [];

  bool showAddTrackerButton = false;
  var task;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getTrackers() async {
    var res = await Api.downloadTracker(widget.id);
    if (res['success']) {
      setState(() {
        loadingTrackers = false;
        trackers = res['data']['items'];
      });
    }
  }

  getPeers() async {
    var res = await Api.downloadPeer(widget.id);
    if (res['success']) {
      setState(() {
        loadingPeers = false;
        peers = res['data']['items'];
      });
    }
  }

  getFiles() async {
    var res = await Api.downloadFile(widget.id);
    if (res['success']) {
      setState(() {
        loadingFiles = false;
        files = res['data']['items'];
      });
    }
  }

  handleTab() {
    if (_tabController.index == 2) {
      setState(() {
        showAddTrackerButton = true;
      });
      getTrackers();
    } else {
      setState(() {
        showAddTrackerButton = false;
      });
    }
    if (_tabController.index == 3) {
      getPeers();
    }
    if (_tabController.index == 4) {
      getFiles();
    }
  }

  getData() async {
    var res = await Api.downloadDetail(widget.id);
    setState(() {
      loading = false;
      if (res['success']) {
        task = res['data']['task'][0];
        if (task['type'] == "bt" && task['status'] == 2) {
          _tabController = TabController(length: 6, vsync: this);
          _tabController.addListener(handleTab);
        } else {
          _tabController = TabController(length: 2, vsync: this);
        }
      }
    });
  }

  Widget _buildFileItem(file) {
    return NeuCard(
      padding: EdgeInsets.all(20),
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Column(
        children: [
          Text(
            "${file['name']}",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text("${Util.formatSize(file['size_downloaded'])} / "),
              Text("${Util.formatSize(file['size'])}"),
              SizedBox(
                width: 10,
              ),
              Text(
                "${(file['size_downloaded'] * 100 / file['size']).toStringAsFixed(2)} %",
                style: TextStyle(color: Colors.blue),
              ),
              Spacer(),
              Label(
                file['priority'] == "normal"
                    ? "??????"
                    : file['priority'] == "high"
                        ? "???"
                        : "???",
                file['priority'] == "normal"
                    ? Colors.blue
                    : file['priority'] == "high"
                        ? Colors.orange
                        : Colors.grey,
                fill: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeerItem(peer) {
    return NeuCard(
      padding: EdgeInsets.all(20),
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Column(
        children: [
          Row(
            children: [
              Text("${peer['ip']}"),
              Spacer(),
              Text("${peer['client']}"),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text("?????????${(peer['progress'] * 100).toStringAsFixed(0)}%"),
              Spacer(),
              Icon(
                Icons.download_sharp,
                color: Colors.green,
                size: 16,
              ),
              Text(
                "${Util.formatSize(peer['speed_download'])}",
                style: TextStyle(color: Colors.green),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.upload_sharp,
                color: Colors.blue,
                size: 16,
              ),
              Text(
                "${Util.formatSize(peer['speed_upload'])}",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerItem(tracker) {
    return NeuCard(
      padding: EdgeInsets.all(20),
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${tracker['url']}"),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                "????????????${tracker['seeds'] >= 0 ? tracker['seeds'] : "-"}",
                style: TextStyle(color: Colors.green),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Peer??????${tracker['peers'] >= 0 ? tracker['peers'] : "-"}",
                style: TextStyle(color: Colors.blue),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  "${tracker['status']}",
                  style: TextStyle(color: tracker['status'] == "Success" ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("????????????"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: NeuButton(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              bevel: 5,
              onPressed: () {
                Util.vibrate(FeedbackType.warning);
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: Colors.transparent,
                      child: NeuCard(
                        width: double.infinity,
                        padding: EdgeInsets.all(22),
                        bevel: 5,
                        curveType: CurveType.emboss,
                        decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "????????????",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              "???????????????????????????",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 22,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      var res = await Api.downloadTaskAction([task['id']], "delete");
                                      if (res['success']) {
                                        Util.toast("??????????????????");
                                        Navigator.of(context).pop(true);
                                      } else {
                                        Util.toast("??????????????????????????????${res['error']['code']}");
                                      }
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "????????????",
                                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: NeuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    bevel: 5,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "??????",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Image.asset(
                "assets/icons/delete.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
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
                        child: Text("??????"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("????????????"),
                      ),
                      if (task['type'] == "bt" && task['status'] == 2) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Text("Tracker?????????"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Text("Peer???"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Text("??????"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Text("??????"),
                        ),
                      ],
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
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("????????????"),
                                Expanded(
                                  child: Text(task['title']),
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Row(
                                children: [
                                  Text("???????????????"),
                                  Expanded(
                                    child: Text(
                                      task['additional']['detail']['destination'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Row(
                                children: [
                                  Text("???????????????"),
                                  Expanded(
                                    child: Text(
                                      "${task['size'] > 0 ? Util.formatSize(task['size']) : "?????????"}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("????????????"),
                                Text("${task['username']}"),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("?????????"),
                                Expanded(child: Text("${task['additional']['detail']['uri']}")),
                                NeuButton(
                                  onPressed: () async {
                                    ClipboardData data = new ClipboardData(text: task['additional']['detail']['uri']);
                                    Clipboard.setData(data);
                                    Util.toast("?????????????????????");
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
                                      Icons.copy,
                                      color: Color(0xffff9813),
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("???????????????"),
                                Text(DateTime.fromMillisecondsSinceEpoch(task['additional']['detail']['created_time'] * 1000).format("Y-m-d H:i:s")),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("???????????????"),
                                Text(task['additional']['detail']['completed_time'] > 0 ? DateTime.fromMillisecondsSinceEpoch(task['additional']['detail']['completed_time'] * 1000).format("Y-m-d H:i:s") : "????????????"),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("?????????????????????"),
                                Text(task['additional']['detail']['waiting_seconds'] > 0 ? Util.timeRemaining(task['additional']['detail']['waiting_seconds']) : "????????????"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("?????????"),
                                Expanded(
                                  child: task['status'] == 1
                                      ? Text(
                                          "?????????",
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      : task['status'] == 2
                                          ? Text(
                                              "${Util.formatSize(task['additional']['transfer']['speed_download'])}/s",
                                              style: TextStyle(color: Colors.lightBlueAccent),
                                            )
                                          : task['status'] == 3
                                              ? Text(
                                                  "?????????",
                                                  style: TextStyle(color: Colors.grey),
                                                )
                                              : task['status'] == 5
                                                  ? Text(
                                                      "?????????",
                                                      style: TextStyle(color: Colors.green),
                                                    )
                                                  : task['status'] == 6
                                                      ? Text(
                                                          "?????????",
                                                          style: TextStyle(color: Colors.grey),
                                                        )
                                                      : task['status'] == 101
                                                          ? Text(
                                                              "??????",
                                                              style: TextStyle(color: Colors.red),
                                                            )
                                                          : task['status'] == 105
                                                              ? Text(
                                                                  "????????????",
                                                                  style: TextStyle(color: Colors.red),
                                                                )
                                                              : task['status'] == 113
                                                                  ? Text(
                                                                      "???????????????",
                                                                      style: TextStyle(color: Colors.red),
                                                                    )
                                                                  : Text(
                                                                      "?????????${task['status']}",
                                                                      style: TextStyle(color: Colors.red),
                                                                    ),
                                ),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Row(
                                children: [
                                  Text("????????????"),
                                  Expanded(
                                    child: Text(
                                      Util.formatSize(task['additional']['transfer']['size_downloaded']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Row(
                                children: [
                                  Text("????????????"),
                                  Expanded(
                                    child: Text(
                                      "${Util.formatSize(task['additional']['transfer']['size_uploaded'])} ???${task['additional']['transfer']['size_downloaded'] > 0 ? (task['additional']['transfer']['size_uploaded'] / task['additional']['transfer']['size_downloaded'] * 100).toStringAsFixed(2) : "0"}%)",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Row(
                                children: [
                                  Text("?????????"),
                                  Expanded(
                                    child: Text(
                                      "${task['size'] > 0 ? (task['additional']['transfer']['size_downloaded'] / task['size'] * 100).toStringAsFixed(2) : "0"}%",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("?????????"),
                                Text("${task['additional']['transfer']['speed_download'] > 0 ? Util.formatSize(task['additional']['transfer']['speed_download']) : "????????????"}"),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Peer??????"),
                                Expanded(child: Text("${task['additional']['detail']['total_peers'] > 0 ? task['additional']['detail']['total_peers'] : "????????????"}")),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("???????????????"),
                                Expanded(child: Text("${task['additional']['detail']['total_pieces'] > 0 ? task['additional']['detail']['total_pieces'] : "????????????"}")),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("?????????????????????"),
                                Text("${task['additional']['transfer']['downloaded_pieces']}"),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("??????????????????"),
                                Text("${Util.timeRemaining(task['additional']['detail']['seed_elapsed'])}"),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("???????????????"),
                                Text("${DateTime.fromMillisecondsSinceEpoch(task['additional']['detail']['started_time'] * 1000).format("Y-m-d H:i:s")}"),
                              ],
                            ),
                          ),
                          NeuCard(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(20),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            curveType: CurveType.flat,
                            bevel: 20,
                            child: Row(
                              children: [
                                Text("???????????????"),
                                Text("${task['additional']['transfer']['speed_download'] > 0 ? Util.timeRemaining(((task['size'] - task['additional']['transfer']['size_downloaded']) / task['additional']['transfer']['speed_download']).ceil()) : "????????????"}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (task['type'] == "bt" && task['status'] == 2) ...[
                        loadingTrackers
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
                            : trackers.length == 0
                                ? Center(
                                    child: Text("???Tracker"),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.all(20),
                                    itemBuilder: (context, i) {
                                      return _buildTrackerItem(trackers[i]);
                                    },
                                    separatorBuilder: (context, i) {
                                      return SizedBox(
                                        height: 20,
                                      );
                                    },
                                    itemCount: trackers.length),
                        loadingPeers
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
                            : peers.length == 0
                                ? Center(
                                    child: Text("???Peer"),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.all(20),
                                    itemBuilder: (context, i) {
                                      return _buildPeerItem(peers[i]);
                                    },
                                    separatorBuilder: (context, i) {
                                      return SizedBox(
                                        height: 20,
                                      );
                                    },
                                    itemCount: peers.length),
                        loadingFiles
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
                            : files.length == 0
                                ? Center(
                                    child: Text("?????????"),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.all(20),
                                    itemBuilder: (context, i) {
                                      return _buildFileItem(files[i]);
                                    },
                                    separatorBuilder: (context, i) {
                                      return SizedBox(
                                        height: 20,
                                      );
                                    },
                                    itemCount: files.length),
                        Center(
                          child: Text("??????????????????"),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: showAddTrackerButton
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .push(CupertinoPageRoute(
                        builder: (context) {
                          return AddTracker(widget.id);
                        },
                        settings: RouteSettings(name: "add_tracker")))
                    .then((res) {
                  if (res != null && res) {
                    getTrackers();
                  }
                });
              },
            )
          : null,
    );
  }
}
