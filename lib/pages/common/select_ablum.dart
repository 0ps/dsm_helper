import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class SelectAlbum extends StatefulWidget {
  final bool multi;
  final bool folder;
  final List<AssetPathEntity> selected;
  SelectAlbum({this.multi = false, this.folder = true, this.selected});
  @override
  _SelectAlbumState createState() => _SelectAlbumState();
}

class _SelectAlbumState extends State<SelectAlbum> {
  ScrollController _scrollController = ScrollController();
  List<AssetPathEntity> albums = [];
  List<AssetPathEntity> selectedAlbums = [];
  bool success = true;
  @override
  void initState() {
    if (widget.selected != null) {
      setState(() {
        selectedAlbums = widget.selected;
      });
    }
    getData();
    super.initState();
  }

  getData() async {
    List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
    setState(() {
      albums = list;
    });
  }

  Widget _buildAlbumItem(AssetPathEntity album) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Opacity(
        opacity: 1,
        child: NeuButton(
          onPressed: () async {
            setState(() {
              if (widget.multi) {
                if (album.isAll) {
                  selectedAlbums = [album];
                } else {
                  selectedAlbums = selectedAlbums.where((element) => !element.isAll).toList();
                  if (selectedAlbums.contains(album)) {
                    selectedAlbums.remove(album);
                  } else {
                    selectedAlbums.add(album);
                  }
                }
              } else {
                selectedAlbums = [album];
              }
            });
          },
          // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          bevel: 8,
          child: Row(
            children: [
              SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${album.name} (${album.assetCount})",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              NeuCard(
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                // onPressed: () {},
                padding: EdgeInsets.all(5),
                bevel: 5,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: selectedAlbums.contains(album)
                      ? Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Color(0xffff9813),
                        )
                      : null,
                ),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Container(
              height: 45,
              color: Theme.of(context).scaffoldBackgroundColor,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: NeuButton(
                      onPressed: albums.length > 1 && selectedAlbums.length > 0
                          ? () {
                              Navigator.of(context).pop(selectedAlbums);
                            }
                          : null,
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 5,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(
                        "完成",
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView(
              padding: EdgeInsets.only(bottom: 20),
              children: albums.map(_buildAlbumItem).toList(),
            )),
          ],
        ),
      ),
    );
  }
}
