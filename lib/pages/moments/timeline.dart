import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:dsm_helper/pages/common/preview.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/moments_api.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Timeline extends StatefulWidget {
  final String category;
  final String type;
  final String title;
  Timeline(this.title, {this.category, this.type});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List timeline = [];
  double photoWidth;
  bool loadingTimeline = true;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await MomentsApi.timeline(category: widget.category, type: widget.type);
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

  getLineInfo(line) async {
    if (line['items'] == null) {
      line['items'] = [];
      MomentsApi.photos(year: line['year'], month: line['month'], day: line['day'], type: widget.type, category: widget.category == "Timeline" ? "Item" : widget.category).then((res) {
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

  Widget _buildPhotoItem(photo) {
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
    String originalUrl = '${Util.baseUrl}/webapi/entry.cgi?id=${photo['additional']['thumbnail']['unit_id']}&cache_key="${photo['additional']['thumbnail']['cache_key']}"&type="unit"&size="xl"&api="SYNO.${Util.version == 7 ? "Foto" : "Photo"}.Thumbnail"&method="get"&version=1&_sid=${Util.sid}';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(TransparentMaterialPageRoute(
          builder: (context) {
            return PreviewPage(
              [originalUrl],
              0,
              tag: "photo-timeline-${photo['additional']['thumbnail']['unit_id']}",
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
              tag: "photo-timeline-${photo['additional']['thumbnail']['unit_id']}",
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
        GridView.builder(
          shrinkWrap: true,
          // crossAxisCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 2, crossAxisSpacing: 2),
          itemCount: line['item_count'],
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            if (items == null || items.length == 0) {
              return Container(
                color: Colors.grey,
                width: photoWidth,
                height: photoWidth,
              );
            } else {
              return _buildPhotoItem(items[i]);
            }
          },
          // children: items == null || items.length == 0
          //     ? List.generate(line['item_count'], (index) {
          //         return Container(
          //           color: Colors.grey,
          //           width: photoWidth,
          //           height: photoWidth,
          //         );
          //       })
          //     : items.map((item) {
          //         return _buildPhotoItem(item);
          //       }).toList(),
        ),
        // Wrap(
        //   spacing: 2,
        //   runSpacing: 2,
        //   children: items == null || items.length == 0
        //       ? List.generate(line['item_count'], (index) {
        //           return Container(
        //             color: Colors.grey,
        //             width: photoWidth,
        //             height: photoWidth,
        //           );
        //         })
        //       : items.map((item) {
        //           return _buildPhotoItem(item);
        //         }).toList(),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (photoWidth == null) {
      photoWidth = (MediaQuery.of(context).size.width - 6) / 4;
    }
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text(widget.title),
      ),
      body: loadingTimeline
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
    );
  }
}
