import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Favorite extends StatefulWidget {
  final Function callback;
  Favorite(this.callback);
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  bool favoriteLoading = true;
  List favorites = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    setState(() {
      favoriteLoading = true;
    });
    var res = await Api.favoriteList();
    setState(() {
      favoriteLoading = false;
    });
    if (res['success']) {
      setState(() {
        favorites = res['data']['favorites'];
      });
    }
  }

  Widget _buildFavoriteItem(favorite) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: NeuButton(
        onPressed: () {
          if (favorite['status'] == "broken") {
            Util.toast("文件或目录不存在");
          } else {
            Navigator.of(context).pop(favorite['path']);
            widget.callback(favorite['path']);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              FileIcon(
                FileType.folder,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(child: Text(favorite['name'])),
              SizedBox(
                width: 10,
              ),
              NeuCard(
                // padding: EdgeInsets.zero,
                curveType: CurveType.flat,
                padding: EdgeInsets.only(left: 6, right: 4, top: 5, bottom: 5),
                decoration: NeumorphicDecoration(
                  // color: Colors.red,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                bevel: 10,
                child: Icon(
                  CupertinoIcons.right_chevron,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        padding: EdgeInsets.zero,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return favoriteLoading
        ? Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
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
            ),
          )
        : Container(
            height: double.infinity,
            color: Colors.white,
            width: MediaQuery.of(context).size.width * 0.7,
            child: favorites.length > 0
                ? ListView.builder(
                    padding: EdgeInsets.only(left: 20, right: 20, top: MediaQuery.of(context).padding.top),
                    itemBuilder: (context, i) {
                      return _buildFavoriteItem(favorites[i]);
                    },
                    itemCount: favorites.length,
                  )
                : Center(
                    child: Text("暂无收藏"),
                  ),
          );
  }
}
