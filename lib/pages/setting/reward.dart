import 'package:dsm_helper/util/api.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Reward extends StatefulWidget {
  @override
  _RewardState createState() => _RewardState();
}

class _RewardState extends State<Reward> {
  bool loading = true;
  List rewards = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.reward();
    if (res['code'] == 1) {
      setState(() {
        loading = false;
        rewards = res['data'];
      });
    } else {
      Util.toast("获取列表失败");
      Navigator.of(context).pop();
    }
  }

  Widget _buildRewardItem(reward) {
    return NeuCard(
      padding: EdgeInsets.all(20),
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Row(
        children: [
          Expanded(child: Text(reward['name'])),
          if (reward['amount'] != null) Text("￥${reward['amount']}"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("打赏名单"),
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
                return _buildRewardItem(rewards[i]);
              },
              itemCount: rewards.length,
              separatorBuilder: (context, i) {
                return SizedBox(
                  height: 20,
                );
              },
            ),
    );
  }
}
