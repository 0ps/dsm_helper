import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:neumorphic/neumorphic.dart';

class UserDetail extends StatefulWidget {
  final Map user;
  UserDetail(this.user);
  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  Map user;
  List groups = [];
  List bandwidthControl = [];
  List volumes = [];
  List quotas = [];
  List permissions = [];
  String password;
  String confirmPassword;
  @override
  void initState() {
    _tabController = TabController(length: 6, vsync: this);
    _nameController.value = TextEditingValue(text: widget.user['name']);
    _descriptionController.value = TextEditingValue(text: widget.user['description']);
    _emailController.value = TextEditingValue(text: widget.user['email']);
    setState(() {
      user = widget.user;
    });
    getData();
    super.initState();
  }

  Widget _buildGroupItem(group) {
    return GestureDetector(
      onTap: () {
        setState(() {
          group['is_member'] = !group['is_member'];
        });
      },
      child: NeuCard(
        curveType: group['is_member'] ? CurveType.emboss : CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 20,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${group['name']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        "${group['description']}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              if (group['is_member'])
                Icon(
                  CupertinoIcons.checkmark_alt,
                  color: Color(0xffff9813),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeItem(volume) {
    List shares = quotas.where((element) => element['volume'] == volume['volume_path']).first['shares'];
    return GestureDetector(
      onTap: () {
        setState(() {
          // group['is_member'] = !group['is_member'];
        });
      },
      child: NeuCard(
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 20,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "${volume['display_name']}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Label("${volume['description']}", Colors.lightBlueAccent),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              ...shares.map(_buildQuotaItem).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaItem(quota) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // group['is_member'] = !group['is_member'];
        });
      },
      child: NeuCard(
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.symmetric(vertical: 10),
        bevel: 20,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${quota['name']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        "${quota['description'] == "" ? "-" : quota['description']}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${Util.formatSize(quota['used'] * 1024 * 1024)}",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                " / ",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "${quota['quota'] == 0 ? "无限制" : Util.formatSize(quota['quota'] * 1024 * 1024)}",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionStatue(permission) {
    if (permission['is_custom'] || permission['is_deny'] || permission['is_readonly'] || permission['is_writable']) {
      return permission['is_readonly']
          ? Label("只读", Colors.lightBlueAccent)
          : permission['is_writable']
              ? Label("可读写", Colors.green)
              : permission['is_custom']
                  ? Label("自定义", Colors.orangeAccent)
                  : permission['is_deny']
                      ? Label("禁止访问", Colors.red)
                      : Label(permission['inherit'], Colors.orangeAccent);
    } else {
      return permission['inherit'] == "ro"
          ? Label("只读", Colors.lightBlueAccent)
          : permission['inherit'] == "rw"
              ? Label("可读写", Colors.green)
              : permission['inherit'] == "cu"
                  ? Label("自定义", Colors.orangeAccent)
                  : permission['inherit'] == "-"
                      ? Label("禁止访问", Colors.red)
                      : Label(permission['inherit'], Colors.orangeAccent);
    }
  }

  Widget _buildPermissionItem(permission) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // group['is_member'] = !group['is_member'];
        });
      },
      child: NeuCard(
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 20,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${permission['name']}",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        _buildPermissionStatue(permission),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getGroup() async {
    var res = await Api.userGroup(user['name']);
    if (res['success']) {
      setState(() {
        groups = res['data']['groups'];
      });
    }
  }

  getData() async {
    getGroup();
    var res = await Api.userDetail(user['name']);
    if (res['success']) {
      List result = res['data']['result'];
      result.forEach((item) {
        if (item['success'] == true) {
          switch (item['api']) {
            case "SYNO.Core.User":
              setState(() {
                user = item['data']['users'][0];
              });
              break;
            case "SYNO.Core.User.PasswordExpiry":
              setState(() {
                // powerRecovery = item['data'];
              });
              break;
            case "SYNO.Core.Share.Permission":
              setState(() {
                permissions = item['data']['shares'];
              });
              break;
            case "SYNO.Core.Storage.Volume":
              setState(() {
                volumes = item['data']['volumes'];
              });
              break;
            case "SYNO.Core.BandwidthControl":
              setState(() {
                bandwidthControl = item['data']['bandwidths'];
              });
              break;
            case "SYNO.Core.OTP.Admin":
              setState(() {});
              break;
            case "SYNO.Core.FileServ.SMB":
              setState(() {});
              break;
            case "SYNO.Core.Quota":
              setState(() {
                quotas = item['data']['user_quota'];
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
        title: Text("${widget.user['name']}"),
      ),
      body: Column(
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
                  child: Text("信息"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("用户群组"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("权限"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("空间配额"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("应用程序"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("速度限制"),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 20,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        controller: _nameController,
                        onChanged: (v) => user['name'] = v,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '名称',
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
                      bevel: 12,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        controller: _descriptionController,
                        onChanged: (v) => user['description'] = v,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '描述',
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
                      bevel: 12,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        controller: _emailController,
                        onChanged: (v) => user['email'] = v,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '电子邮件',
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
                      bevel: 12,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        onChanged: (v) => password = v,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '修改密码',
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
                      bevel: 12,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        onChanged: (v) => confirmPassword = v,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '确认密码',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          user['cannot_chg_passwd'] = !user['cannot_chg_passwd'];
                        });
                      },
                      child: NeuCard(
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        curveType: user['cannot_chg_passwd'] ?? false ? CurveType.emboss : CurveType.flat,
                        bevel: 12,
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          children: [
                            Text("不允许此用户修改密码"),
                            Spacer(),
                            if (user['cannot_chg_passwd'] ?? false)
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
                          // user['passwd_never_expire'] = !user['passwd_never_expire'];
                        });
                      },
                      child: NeuCard(
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        curveType: user['passwd_never_expire'] ?? false ? CurveType.emboss : CurveType.flat,
                        bevel: 12,
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          children: [
                            Text("密码始终有效"),
                            Spacer(),
                            if (user['passwd_never_expire'] ?? false)
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
                          if (user['expired'] != "normal") {
                            user['expired'] = "normal";
                          } else {
                            user['expired'] = "now";
                          }
                        });
                      },
                      child: NeuCard(
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        curveType: user['expired'] != "normal" ? CurveType.emboss : CurveType.flat,
                        bevel: 20,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "停用此用户账户",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Spacer(),
                                  if (user['expired'] != "normal")
                                    Icon(
                                      CupertinoIcons.checkmark_alt,
                                      color: Color(0xffff9813),
                                    ),
                                ],
                              ),
                              if (user['expired'] != "normal")
                                NeuCard(
                                  margin: EdgeInsets.only(top: 20),
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  curveType: CurveType.flat,
                                  bevel: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                user['expired'] = "now";
                                              });
                                            },
                                            child: NeuCard(
                                              // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                              padding: EdgeInsets.all(15),
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              curveType: user['expired'] == "now" ? CurveType.emboss : CurveType.flat,
                                              bevel: 20,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "立即",
                                                        style: TextStyle(fontSize: 16, height: 1.6),
                                                      ),
                                                      Spacer(),
                                                      if (user['expired'] == "now")
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                        ),
                                                    ],
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
                                          flex: 3,
                                          child: GestureDetector(
                                            onTap: () {
                                              DatePicker.showDatePicker(context, locale: LocaleType.zh, currentTime: DateTime.now(), onConfirm: (v) {
                                                setState(() {
                                                  user['expired'] = v.format("Y-m-d");
                                                  print(user['expired']);
                                                });
                                              });
                                            },
                                            child: NeuCard(
                                              // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                              padding: EdgeInsets.all(15),
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              curveType: user['expired'] != "now" ? CurveType.emboss : CurveType.flat,
                                              bevel: 20,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${user['expired'] == "now" ? "到期于：" : user['expired']}",
                                                        style: TextStyle(fontSize: 16, height: 1.6),
                                                      ),
                                                      Spacer(),
                                                      if (user['expired'] != "now")
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                ListView.separated(
                  padding: EdgeInsets.all(20),
                  itemBuilder: (context, i) {
                    return _buildGroupItem(groups[i]);
                  },
                  itemCount: groups.length,
                  separatorBuilder: (context, i) {
                    return SizedBox(
                      height: 20,
                    );
                  },
                ),
                ListView.separated(
                  padding: EdgeInsets.all(20),
                  itemBuilder: (context, i) {
                    return _buildPermissionItem(permissions[i]);
                  },
                  itemCount: permissions.length,
                  separatorBuilder: (context, i) {
                    return SizedBox(
                      height: 20,
                    );
                  },
                ),
                ListView.separated(
                  padding: EdgeInsets.all(20),
                  itemBuilder: (context, i) {
                    return _buildVolumeItem(volumes[i]);
                  },
                  itemCount: volumes.length,
                  separatorBuilder: (context, i) {
                    return SizedBox(
                      height: 20,
                    );
                  },
                ),
                ListView(),
                ListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
