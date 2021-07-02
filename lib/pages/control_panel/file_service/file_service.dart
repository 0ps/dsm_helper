import 'package:dsm_helper/pages/control_panel/file_service/log_setting.dart';
import 'package:dsm_helper/pages/log_center/log_center.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/neu_picker.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';

class FileService extends StatefulWidget {
  @override
  _FileServiceState createState() => _FileServiceState();
}

class _FileServiceState extends State<FileService> with SingleTickerProviderStateMixin {
  TextEditingController _workgroupController = TextEditingController();
  TextEditingController _nfsv4Controller = TextEditingController();
  TextEditingController _timeoutController = TextEditingController();
  TextEditingController _ftpPortController = TextEditingController();
  TextEditingController _sftpPortController = TextEditingController();
  List utf8Modes = ['禁用', '自动', '强制'];
  bool loading = true;
  TabController _tabController;
  Map smb;
  Map afp;
  Map nfs;
  Map ftp;
  Map sftp;
  Map bandwidth;
  Map tftp;
  Map backup;
  Map serviceDiscovery;
  Map bonjourSharing;
  Map syslogClient;
  bool enableWstransfer;
  bool saving = false;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
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
                _timeoutController.value = TextEditingValue(text: "${ftp['timeout']}");
                _ftpPortController.value = TextEditingValue(text: "${ftp['portnum']}");
              });
              break;
            case "SYNO.Core.FileServ.FTP.SFTP":
              setState(() {
                sftp = item['data'];
                print(sftp);
                _sftpPortController.value = TextEditingValue(text: "${sftp['portnum']}");
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
                      // Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      //   child: Text("TFTP"),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      //   child: Text("rsync"),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      //   child: Text("高级设置"),
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        children: [
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
                                        if (syslogClient['cifs']) {
                                          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                            return LogSetting("cifs");
                                          }));
                                        }
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
                                    if (syslogClient['cifs']) ...[
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: NeuButton(
                                              onPressed: () {
                                                if (syslogClient['cifs']) {
                                                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                                    return LogSetting("cifs");
                                                  }));
                                                }
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                              child: Text("日志设置"),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: NeuButton(
                                              onPressed: () {
                                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                                  return LogCenter();
                                                }));
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                              child: Text(
                                                "查看日志",
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
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
                      ListView(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        children: [
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
                                    "FTP/FTPS",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        ftp['enable_ftp'] = !ftp['enable_ftp'];
                                      });
                                    },
                                    child: NeuCard(
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      height: 60,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                      curveType: ftp['enable_ftp'] ? CurveType.emboss : CurveType.flat,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "启用FTP服务",
                                            ),
                                          ),
                                          if (ftp['enable_ftp'])
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
                                        ftp['enable_ftps'] = !ftp['enable_ftps'];
                                      });
                                    },
                                    child: NeuCard(
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      height: 60,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                      curveType: ftp['enable_ftps'] ? CurveType.emboss : CurveType.flat,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "启用 FTP SSL/TLS 加密服务（FTPS）",
                                            ),
                                          ),
                                          if (ftp['enable_ftps'])
                                            Icon(
                                              CupertinoIcons.checkmark_alt,
                                              color: Color(0xffff9813),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (ftp['enable_ftps']) ...[
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
                                        controller: _timeoutController,
                                        onChanged: (v) {
                                          try {
                                            ftp['timeout'] = int.parse(v);
                                          } catch (e) {
                                            print("error");
                                          }
                                        },
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: '超时(1-7200秒)',
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
                                      bevel: 20,
                                      curveType: CurveType.flat,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                      child: NeuTextField(
                                        controller: _ftpPortController,
                                        onChanged: (v) {
                                          try {
                                            ftp['portnum'] = int.parse(v);
                                          } catch (e) {
                                            print("error");
                                          }
                                        },
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'FTP 服务所使用的端口号',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          ftp['enable_fxp'] = !ftp['enable_fxp'];
                                        });
                                      },
                                      child: NeuCard(
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        height: 60,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        curveType: ftp['enable_fxp'] ? CurveType.emboss : CurveType.flat,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "启用 FXP",
                                              ),
                                            ),
                                            if (ftp['enable_fxp'])
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
                                          ftp['enable_fips'] = !ftp['enable_fips'];
                                        });
                                      },
                                      child: NeuCard(
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        height: 60,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        curveType: ftp['enable_fips'] ? CurveType.emboss : CurveType.flat,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "启用 FIPS 加密模块",
                                              ),
                                            ),
                                            if (ftp['enable_fips'])
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
                                          ftp['enable_ascii'] = !ftp['enable_ascii'];
                                        });
                                      },
                                      child: NeuCard(
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        height: 60,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        curveType: ftp['enable_ascii'] ? CurveType.emboss : CurveType.flat,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "支持 ASCII 传送模式",
                                              ),
                                            ),
                                            if (ftp['enable_ascii'])
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
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        showCupertinoModalPopup(
                                          context: context,
                                          builder: (context) {
                                            return NeuPicker(
                                              utf8Modes,
                                              value: ftp['utf8_mode'],
                                              onConfirm: (v) {
                                                setState(() {
                                                  ftp['utf8_mode'] = v;
                                                });
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: NeuCard(
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.all(20),
                                        curveType: CurveType.flat,
                                        child: Row(
                                          children: [
                                            Text("UTF-8 编码:"),
                                            Spacer(),
                                            Text("${utf8Modes[ftp['utf8_mode']]}"),
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
                                    "SFTP",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        sftp['enable'] = !sftp['enable'];
                                      });
                                    },
                                    child: NeuCard(
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      height: 60,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                      curveType: sftp['enable'] ? CurveType.emboss : CurveType.flat,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "启用SFTP服务",
                                            ),
                                          ),
                                          if (sftp['enable'])
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
                                  NeuCard(
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    bevel: 20,
                                    curveType: CurveType.flat,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                    child: NeuTextField(
                                      controller: _sftpPortController,
                                      onChanged: (v) {
                                        try {
                                          sftp['portnum'] = int.parse(v);
                                        } catch (e) {
                                          print("error");
                                        }
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: '端口号',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Center(),
                      // Center(),
                      // Center(),
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
                      if (saving) {
                        return;
                      }
                      setState(() {
                        saving = true;
                      });
                      var res = await Api.fileServiceSave(smb, syslogClient, afp, nfs, ftp, sftp);

                      if (res['success']) {
                        setState(() {
                          saving = false;
                        });
                        Util.toast("保存成功");
                        getData();
                      }
                    },
                    child: saving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoActivityIndicator(),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                ' 保存中 ',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          )
                        : Text(
                            ' 保存 ',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                )
              ],
            ),
    );
  }
}
