import 'package:dsm_helper/pages/common/preview.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/moments_api.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class Photos extends StatefulWidget {
  final Map album;
  final Object tag;
  Photos(this.album, {this.tag});
  @override
  _PhotosState createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {
  double photoWidth;
  List photos = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await MomentsApi.photos(albumId: widget.album['id']);
    if (res['success']) {
      setState(() {
        photos = res['data']['list'];
      });
    }
  }

  Widget _buildPhotoItem(photo) {
    String thumbUrl = '${Util.baseUrl}/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key="${photo['additional']['thumbnail']['cache_key']}"&type="unit"&size="sm"&api="SYNO.Photo.Thumbnail"&method="get"&version=1&_sid=${Util.sid}';
    String originalUrl = '${Util.baseUrl}/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key="${photo['additional']['thumbnail']['cache_key']}"&type="unit"&size="xl"&api="SYNO.Photo.Thumbnail"&method="get"&version=1&_sid=${Util.sid}';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(TransparentMaterialPageRoute(
          builder: (context) {
            return PreviewPage(
              [originalUrl],
              0,
              tag: "photo-${photo['additional']['thumbnail']['unit_id']}",
            );
          },
          fullscreenDialog: true,
        ));
      },
      child: Container(
        width: photoWidth,
        height: photoWidth,
        child: Stack(
          children: [
            Hero(
              tag: "photo-${photo['additional']['thumbnail']['unit_id']}",
              child: CupertinoExtendedImage(
                // "http://pan.fmtol.com:5000/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key=%22${photo['additional']['thumbnail']['cache_key']}%22&type=%22unit%22&size=%22sm%22&api=%22SYNO.Photo.Thumbnail%22&method=%22get%22&version=1&_sid=${Util.sid}",
                thumbUrl,
                width: photoWidth,
                height: photoWidth,
                fit: BoxFit.cover,
                placeholder: Container(
                  width: photoWidth,
                  height: photoWidth,
                  color: Color(0xffE9E9E9),
                ),
              ),
            ),
            if (photo['type'] == "video")
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${Util.timeLong(5235)['hours'].toString().padLeft(2, "0")}:${Util.timeLong(5235)['minutes'].toString().padLeft(2, "0")}:${Util.timeLong(5235)['seconds'].toString().padLeft(2, "0")}",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (photoWidth == null) {
      photoWidth = (MediaQuery.of(context).size.width - 6) / 4;
    }
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              leading: AppBackButton(context),
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "${widget.album['name']}",
                  style: TextStyle(color: Theme.of(context).textTheme.headline6.color, shadows: [BoxShadow(color: Colors.white, offset: Offset(1, 1), blurRadius: 5, spreadRadius: 5)]),
                ),
                centerTitle: true,
                background: Hero(
                  tag: widget.tag,
                  child: CupertinoExtendedImage(
                    '${Util.baseUrl}/webapi/entry.cgi?id=${widget.album['additional']['thumbnail']['unit_id']}&cache_key="${widget.album['additional']['thumbnail']['cache_key']}"&type="unit"&size="xl"&api="SYNO.Photo.Thumbnail"&method="get"&version=1&_sid=${Util.sid}',
                    fit: BoxFit.cover,
                    height: 200,
                    placeholder: CupertinoExtendedImage(
                      '${Util.baseUrl}/webapi/entry.cgi?id=${widget.album['additional']['thumbnail']['unit_id']}&cache_key="${widget.album['additional']['thumbnail']['cache_key']}"&type="unit"&size="sm"&api="SYNO.Photo.Thumbnail"&method="get"&version=1&_sid=${Util.sid}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              expandedHeight: 200.0,
            )
          ];
        },
        body: ListView(
          padding: EdgeInsets.only(top: 2),
          children: [
            Wrap(
              spacing: 2,
              runSpacing: 2,
              children: photos.length == 0
                  ? List.generate(widget.album['item_count'], (index) {
                      return Container(
                        color: Colors.grey,
                        width: photoWidth,
                        height: photoWidth,
                      );
                    })
                  : photos.map((item) {
                      return _buildPhotoItem(item);
                    }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
