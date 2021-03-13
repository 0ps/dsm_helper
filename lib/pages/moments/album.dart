import 'package:dsm_helper/pages/moments/photos.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/moments_api.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Album extends StatefulWidget {
  final bool shared;
  final String title;
  Album(this.title, {this.shared: false});
  @override
  _AlbumState createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  bool loadingAlbum = true;
  double albumWidth;
  List album = [];
  @override
  void initState() {
    getAlbum();
    super.initState();
  }

  getAlbum() async {
    var res = await MomentsApi.album(shared: true);
    if (res['success'] && mounted) {
      setState(() {
        album = res['data']['list'];
        loadingAlbum = false;
      });
    }
  }

  Widget _buildAlbumItem(album) {
    String thumbUrl = '${Util.baseUrl}/webapi/entry.cgi?id=${album['additional']['thumbnail']['unit_id']}&cache_key="${album['additional']['thumbnail']['cache_key']}"&type="unit"&size="sm"&api="SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Thumbnail"&method="get"&version=1&_sid=${Util.sid}';
    String tag = "album-${album['additional']['thumbnail']['unit_id']}";
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) {
            return Photos(album, tag: tag);
          },
        ));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: albumWidth,
            height: albumWidth,
            child: Hero(
              tag: "album-${album['additional']['thumbnail']['unit_id']}",
              child: CupertinoExtendedImage(
                // "http://pan.fmtol.com:5000/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key=%22${photo['additional']['thumbnail']['cache_key']}%22&type=%22unit%22&size=%22sm%22&api=%22SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Thumbnail%22&method=%22get%22&version=1&_sid=${Util.sid}",
                thumbUrl,
                width: albumWidth,
                height: albumWidth,
                fit: BoxFit.cover,
                boxShape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                placeholder: Container(
                  width: albumWidth,
                  height: albumWidth,
                  color: Color(0xffE9E9E9),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "${album['name']}",
            style: TextStyle(fontSize: 14),
            maxLines: 1,
          ),
          Text(
            "${album['item_count']}",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (albumWidth == null) {
      albumWidth = (MediaQuery.of(context).size.width - 80) / 3;
    }
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(widget.title),
      ),
      body: loadingAlbum
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
          : album.length > 0
              ? ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    Wrap(
                      runSpacing: 20,
                      spacing: 20,
                      children: [
                        ...album.map(_buildAlbumItem).toList(),
                      ],
                    )
                  ],
                )
              : Container(
                  height: 500,
                  child: Center(
                    child: Text("无手动创建的相册"),
                  ),
                ),
    );
  }
}
