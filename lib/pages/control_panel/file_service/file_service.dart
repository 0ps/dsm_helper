import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class FileService extends StatefulWidget {
  @override
  _FileServiceState createState() => _FileServiceState();
}

class _FileServiceState extends State<FileService> with SingleTickerProviderStateMixin {
  TextEditingController _workgroupController = TextEditingController();
  TextEditingController _nfsv4Controller = TextEditingController();
  bool loading = true;
  TabController _tabController;
  Map smb;
  Map afp;
  Map nfs;
  Map ftp;
  Map bandwidth;
  Map tftp;
  Map backup;
  Map serviceDiscovery;
  Map bonjourSharing;
  Map syslogClient;
  bool enableWstransfer;
  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.fileService();
    if (res['success']) {
      setState(() {
        loading = false;
      });
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.Core.FileServ.SMB":
              setState(() {
                smb = item['data'];
                _workgroupController.value = TextEditingValue(text: smb['workgroup'] ?? "");
              });
              break;
            case "SYNO.Core.FileServ.AFP":
              setState(() {
                afp = item['data'];
              });
              break;
            case "SYNO.Core.FileServ.NFS":
              setState(() {
                nfs = item['data'];
              });
              _nfsv4Controller.value = TextEditingValue(text: nfs['nfs_v4_domain'] ?? "");
              break;
            case "SYNO.Core.FileServ.FTP":
              setState(() {
                ftp = item['data'];
              });
              break;
            case "SYNO.Core.BandwidthControl.Protocol":
              setState(() {
                bandwidth = item['data'];
              });
              break;
            case "SYNO.Core.TFTP":
              setState(() {
                tftp = item['data'];
              });
              break;
            case "SYNO.Backup.Service.NetworkBackup":
              setState(() {
                backup = item['data'];
              });
              break;
            case "SYNO.Core.ExternalDevice.Printer.BonjourSharing":
              setState(() {
                bonjourSharing = item['data'];
              });
              break;
            case "SYNO.Core.FileServ.ServiceDiscovery":
              setState(() {
                serviceDiscovery = item['data'];
              });
              break;
            case "SYNO.Core.SyslogClient.FileTransfer":
              setState(() {
                syslogClient = item['data'];
              });
              break;
            case "SYNO.Core.FileServ.ServiceDiscovery.WSTransfer":
              setState(() {
                enableWstransfer = item['data']['enable_wstransfer'];
              });
              break;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("文件服务"),
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
                        child: Text("SMB/AFP/NFS"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("FTP"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("TFTP"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("rsync"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("高级设置"),
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
                                SizedBox(
                                  height: 20,
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "SMB",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              smb['enable_samba'] = !smb['enable_samba'];
                                            });
                                          },
                                          child: NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            height: 60,
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                            curveType: smb['enable_samba'] ? CurveType.emboss : CurveType.flat,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "启用SMB服务",
                                                  ),
                                                ),
                                                if (smb['enable_samba'])
                                                  Icon(
                                                    CupertinoIcons.checkmark_alt,
                                                    color: Color(0xffff9813),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (smb['enable_samba']) ...[
                                          SizedBox(
                                            height: 20,
                                          ),
                                          NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            bevel: 20,
                                            curveType: CurveType.flat,
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                            child: NeuTextField(
                                              controller: _workgroupController,
                                              onChanged: (v) => smb['workgroup'] = v,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                labelText: '工作群组',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                smb['disable_shadow_copy'] = !smb['disable_shadow_copy'];
                                              });
                                            },
                                            child: NeuCard(
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              height: 60,
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                              curveType: smb['disable_shadow_copy'] ? CurveType.emboss : CurveType.flat,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "不可访问以前版本",
                                                    ),
                                                  ),
                                                  if (smb['disable_shadow_copy'])
                                                    Icon(
                                                      CupertinoIcons.checkmark_alt,
                                                      color: Color(0xffff9813),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                syslogClient['cifs'] = !syslogClient['cifs'];
                                              });
                                            },
                                            child: NeuCard(
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              height: 60,
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                              curveType: syslogClient['cifs'] ? CurveType.emboss : CurveType.flat,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "启动传输日志",
                                                    ),
                                                  ),
                                                  if (syslogClient['cifs'])
                                                    Icon(
                                                      CupertinoIcons.checkmark_alt,
                                                      color: Color(0xffff9813),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "AFP",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              afp['enable_afp'] = !afp['enable_afp'];
                                            });
                                          },
                                          child: NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            height: 60,
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                            curveType: afp['enable_afp'] ? CurveType.emboss : CurveType.flat,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "启用AFP服务",
                                                  ),
                                                ),
                                                if (afp['enable_afp'])
                                                  Icon(
                                                    CupertinoIcons.checkmark_alt,
                                                    color: Color(0xffff9813),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (afp['enable_afp']) ...[
                                          SizedBox(
                                            height: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                syslogClient['afp'] = !syslogClient['afp'];
                                              });
                                            },
                                            child: NeuCard(
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              height: 60,
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                              curveType: syslogClient['afp'] ? CurveType.emboss : CurveType.flat,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "启动传输日志",
                                                    ),
                                                  ),
                                                  if (syslogClient['afp'])
                                                    Icon(
                                                      CupertinoIcons.checkmark_alt,
                                                      color: Color(0xffff9813),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "NFS",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              nfs['enable_nfs'] = !nfs['enable_nfs'];
                                            });
                                          },
                                          child: NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            height: 60,
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                            curveType: nfs['enable_nfs'] ? CurveType.emboss : CurveType.flat,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "启用NFS服务",
                                                  ),
                                                ),
                                                if (nfs['enable_nfs'])
                                                  Icon(
                                                    CupertinoIcons.checkmark_alt,
                                                    color: Color(0xffff9813),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (nfs['enable_nfs']) ...[
                                          SizedBox(
                                            height: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                nfs['enable_nfs_v4'] = !nfs['enable_nfs_v4'];
                                              });
                                            },
                                            child: NeuCard(
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              height: 60,
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                              curveType: nfs['enable_nfs_v4'] ? CurveType.emboss : CurveType.flat,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "启用 NFSv4.1 支持",
                                                    ),
                                                  ),
                                                  if (nfs['enable_nfs_v4'])
                                                    Icon(
                                                      CupertinoIcons.checkmark_alt,
                                                      color: Color(0xffff9813),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (nfs['enable_nfs'] && nfs['enable_nfs_v4']) ...[
                                          SizedBox(
                                            height: 20,
                                          ),
                                          NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            bevel: 20,
                                            curveType: CurveType.flat,
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                            child: NeuTextField(
                                              controller: _nfsv4Controller,
                                              onChanged: (v) => nfs['nfs_v4_domain'] = v,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                labelText: 'NFSv4 域',
                                              ),
                                            ),
                                          ),
                                        ],
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
                                var res = await Api.fileServiceSave(smb, syslogClient, afp, nfs);
                                print(res);
                                if (res['success']) {
                                  Util.toast("保存成功");
                                  getData();
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
                      Center(),
                      Center(),
                      Center(),
                      Center(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
