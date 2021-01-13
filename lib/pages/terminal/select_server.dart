import 'dart:convert';

import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'add_server.dart';
import 'ssh.dart';

class SelectServer extends StatefulWidget {
  @override
  _SelectServerState createState() => _SelectServerState();
}

class _SelectServerState extends State<SelectServer> {
  bool loading = true;
  List servers = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    String str = await Util.getStorage("terminal_servers");
    setState(() {
      loading = false;
      if (str.isNotBlank) {
        servers = json.decode(str);
      } else {
        servers = [];
      }
    });
    print(servers);
  }

  Widget _buildServerItem(server) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: NeuButton(
        onPressed: () async {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) {
                return Ssh(server['host'], server['port'], server['account'], server['password']);
              },
              settings: RouteSettings(name: "ssh_client")));
        },
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.zero,
        bevel: 20,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${server['account']}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${server['host']}:${server['port']}",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              NeuButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    servers.remove(server);
                  });

                  Util.setStorage("terminal_servers", jsonEncode(servers));
                  Util.toast("删除成功");
                },
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                bevel: 20,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Image.asset(
                  "assets/icons/delete.png",
                  width: 20,
                ),
              ),
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
        title: Text("选择服务器"),
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
                Navigator.of(context)
                    .push(CupertinoPageRoute(
                        builder: (context) {
                          return AddServer();
                        },
                        settings: RouteSettings(name: "add_ssh_server")))
                    .then((value) {
                  getData();
                });
              },
              child: Icon(Icons.add),
            ),
          )
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
          : servers.length > 0
              ? ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemBuilder: (context, i) {
                    return _buildServerItem(servers[i]);
                  },
                  itemCount: servers.length,
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "未添加服务器",
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: NeuButton(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          bevel: 5,
                          onPressed: () {
                            Navigator.of(context)
                                .push(CupertinoPageRoute(
                                    builder: (context) {
                                      return AddServer();
                                    },
                                    settings: RouteSettings(name: "add_ssh_server")))
                                .then((value) {
                              getData();
                            });
                          },
                          child: Text(
                            ' 添加 ',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
