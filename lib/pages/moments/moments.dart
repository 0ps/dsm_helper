import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:dsm_helper/pages/common/preview.dart';
import 'package:dsm_helper/pages/moments/album.dart';
import 'package:dsm_helper/pages/moments/photos.dart';
import 'package:dsm_helper/pages/moments/timeline.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/moments_api.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Moments extends StatefulWidget {
  @override
  _MomentsState createState() => _MomentsState();
}

class _MomentsState extends State<Moments> {
  int currentIndex = 0;
  ScrollController _scrollController = ScrollController();
  List timeline = [];
  List category = [];
  List album = [];
  List recentlyAdd = [];
  List videos = [];
  List shares = [];
  double photoWidth;
  double albumWidth;
  bool loadingTimeline = true;
  bool loadingAlbum = true;
  @override
  void initState() {
    getData();
    // getCategory();
    getAlbum();
    getRecently();
    getVideos();
    getShares();
    super.initState();
  }

  getData() async {
    var res = await MomentsApi.timeline();
    if (res['success'] && mounted) {
      setState(() {
        timeline = [];
        if (Util.version == 7) {
          for (var section in res['data']['section']) {
            timeline.addAll(section['list']);
          }
        } else {
          timeline = res['data']['list'];
        }

        for (int i = 0; i < timeline.length; i++) {
          int lines = (timeline[i]['item_count'] / 4).ceil();
          double height = 40 + lines * photoWidth + (lines - 1) * 2;
          timeline[i]['position'] = {};
          if (i == 0) {
            timeline[i]['position']['start'] = 0;
            timeline[i]['position']['end'] = height;
          } else {
            timeline[i]['position']['start'] = timeline[i - 1]['position']['end'];
            timeline[i]['position']['end'] = timeline[i]['position']['start'] + height;
          }
        }
        setState(() {
          loadingTimeline = false;
        });
      });
    }
  }

  getCategory() async {
    var res = await MomentsApi.category();
    if (res['success'] && mounted) {
      setState(() {
        category = res['data'];
      });
    }
  }

  getAlbum() async {
    var res = await MomentsApi.album();
    if (res['success'] && mounted) {
      setState(() {
        album = res['data']['list'];
        loadingAlbum = false;
      });
    }
  }

  getRecently() async {
    var res = await MomentsApi.photos(category: "RecentlyAdded", limit: 4);
    if (res['success'] && mounted) {
      setState(() {
        recentlyAdd = res['data']["list"];
      });
    }
  }

  getShares() async {
    var res = await MomentsApi.album(shared: true, limit: 4);
    if (res['success'] && mounted) {
      setState(() {
        shares = res['data']["list"];
        print(shares);
      });
    }
  }

  getVideos() async {
    var res = await MomentsApi.photos(type: "video", limit: 4);
    if (res['success'] && mounted) {
      setState(() {
        videos = res['data']["list"];
      });
    }
  }

  getLineInfo(line) async {
    if (line['items'] == null) {
      line['items'] = [];
      MomentsApi.photos(year: line['year'], month: line['month'], day: line['day']).then((res) {
        if (res['success'] && mounted) {
          setState(() {
            line['items'] = res['data']['list'];
          });
        }
      });
    }
    if (line['location'] == null) {
      line['location'] = {};
      MomentsApi.location(line['year'], line['month'], line['day']).then((res) {
        if (res['success'] && mounted) {
          setState(() {
            line['location'] = res['data'];
          });
        }
      });
    }
  }

  Widget _buildPhotoItem(photo, List photos) {
    int duration = 0;
    Map timeLong;
    if (photo['type'] == "video") {
      if (photo['additional']['video_convert'].length > 0) {
        duration = photo['additional']['video_convert'][0]['metadata']['duration'] ~/ 1000;
        timeLong = Util.timeLong(duration);
      } else {
        timeLong = {
          "hours": 0,
          "minutes": 0,
          "seconds": 0,
        };
      }
    }
    String thumbUrl = '${Util.baseUrl}/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key="${photo['additional']['thumbnail']['cache_key']}"&type="unit"&size="sm"&api="SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Thumbnail"&method="get"&version=1&_sid=${Util.sid}';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(TransparentMaterialPageRoute(
          builder: (context) {
            return PreviewPage(
              photos
                  .map((photo) =>
                      '${Util.baseUrl}/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key="${photo['additional']['thumbnail']['cache_key']}"&type="unit"&size="xl"&api="SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Thumbnail"&method="get"&version=1&_sid=${Util.sid}')
                  .toList(),
              photos.indexOf(photo),
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
                // "http://pan.fmtol.com:5000/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key=%22${photo['additional']['thumbnail']['cache_key']}%22&type=%22unit%22&size=%22sm%22&api=%22${Util.version == 7 ? "Foto" : "Photo"}.Thumbnail%22&method=%22get%22&version=1&_sid=${Util.sid}",
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
                      "${timeLong['hours'].toString().padLeft(2, "0")}:${timeLong['minutes'].toString().padLeft(2, "0")}:${timeLong['seconds'].toString().padLeft(2, "0")}",
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

  Widget _buildTimelineItem(line) {
    getLineInfo(line);
    List items = line['items'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                "${line['year']}-${line['month'].toString().padLeft(2, "0")}-${line['day'].toString().padLeft(2, "0")}",
              ),
              if (line['location'] != null && ((line['location']['first_level'] != null && line['location']['first_level'] != ""))) Text("   ${line['location']['first_level']}"),
              if (line['location'] != null && ((line['location']['second_level'] != null && line['location']['second_level'].length > 0))) Text("${line['location']['second_level'].join(",")}"),
            ],
          ),
        ),
        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: items == null || items.length == 0
              ? List.generate(line['item_count'], (index) {
                  return Container(
                    color: Colors.grey,
                    width: photoWidth,
                    height: photoWidth,
                  );
                })
              : items.map((item) {
                  return _buildPhotoItem(item, items);
                }).toList(),
        ),
      ],
    );
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

  Widget _buildCategoryItem(List photos, int index) {
    double itemWidth = (albumWidth - 2) / 2;
    if (index < photos.length) {
      Map photo = photos[index];
      String thumbUrl = '${Util.baseUrl}/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key="${photo['additional']['thumbnail']['cache_key']}"&type="unit"&size="sm"&api="SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Thumbnail"&method="get"&version=1&_sid=${Util.sid}';
      return Container(
        width: itemWidth,
        height: itemWidth,
        child: CupertinoExtendedImage(
          // "http://pan.fmtol.com:5000/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key=%22${photo['additional']['thumbnail']['cache_key']}%22&type=%22unit%22&size=%22sm%22&api=%22SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Thumbnail%22&method=%22get%22&version=1&_sid=${Util.sid}",
          thumbUrl,
          width: itemWidth,
          height: itemWidth,
          fit: BoxFit.cover,
          boxShape: BoxShape.rectangle,
          placeholder: Container(
            width: itemWidth,
            height: itemWidth,
            color: Color(0xffE9E9E9),
          ),
        ),
      );
    } else {
      return Container(
        width: itemWidth,
        height: itemWidth,
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (photoWidth == null) {
      photoWidth = (MediaQuery.of(context).size.width - 6) / 4;
    }
    if (albumWidth == null) {
      albumWidth = (MediaQuery.of(context).size.width - 80) / 3;
    }
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: NeuSwitch(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          thumbColor: Theme.of(context).scaffoldBackgroundColor,
          children: {
            0: Text("图片"),
            1: Text("相册"),
          },
          groupValue: currentIndex,
          onValueChanged: (v) {
            setState(() {
              currentIndex = v;
            });
          },
        ),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          loadingTimeline
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
              : timeline.length > 0
                  ? DraggableScrollbar.semicircle(
                      labelTextBuilder: (position) {
                        var line = timeline.where((element) => element['position']['start'] <= position && element['position']['end'] >= position).toList();
                        if (line.length > 0) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${line[0]['month']}月",
                                  style: TextStyle(fontSize: 30),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("${line[0]['day'].toString().padLeft(2, "0")}日"),
                                    Text("${line[0]['year']}"),
                                  ],
                                )
                              ],
                            ),
                          );
                        } else {
                          return null;
                        }
                      },
                      labelConstraints: BoxConstraints(minHeight: 60, maxHeight: 60, minWidth: 140, maxWidth: 140),
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemBuilder: (context, i) {
                          return _buildTimelineItem(timeline[i]);
                        },
                        itemCount: timeline.length,
                      ),
                    )
                  : Center(
                      child: Text("无项目"),
                    ),
          loadingAlbum
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
              : Container(
                  child: ListView(
                    padding: EdgeInsets.all(20),
                    children: [
                      Wrap(
                        runSpacing: 20,
                        spacing: 20,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) {
                                  return Album(
                                    "与他人共享",
                                    shared: true,
                                  );
                                },
                              ));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: albumWidth,
                                    height: albumWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Wrap(
                                      runSpacing: 2,
                                      spacing: 2,
                                      children: [
                                        ...List.generate(4, (index) {
                                          return _buildCategoryItem(shares, index);
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "共享",
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) {
                                  return Timeline(
                                    "视频",
                                    category: "Timeline",
                                    type: "video",
                                  );
                                },
                              ));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: albumWidth,
                                    height: albumWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Wrap(
                                      runSpacing: 2,
                                      spacing: 2,
                                      children: [
                                        ...List.generate(4, (index) {
                                          return _buildCategoryItem(videos, index);
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "视频",
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) {
                                  return Timeline(
                                    "最近添加的",
                                    category: "RecentlyAdded",
                                  );
                                },
                              ));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: albumWidth,
                                    height: albumWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Wrap(
                                      runSpacing: 2,
                                      spacing: 2,
                                      children: [
                                        ...List.generate(4, (index) {
                                          return _buildCategoryItem(recentlyAdd, index);
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "最近添加的",
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      album.length > 0
                          ? Wrap(
                              runSpacing: 20,
                              spacing: 20,
                              children: [
                                ...album.map(_buildAlbumItem).toList(),
                              ],
                            )
                          : Container(
                              height: 500,
                              child: Center(
                                child: Text("无手动创建的相册"),
                              ),
                            ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
