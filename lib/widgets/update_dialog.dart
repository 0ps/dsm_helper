import 'package:dsm_helper/pages/update/update.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class UpdateDialog extends StatelessWidget {
  final Map updateInfo;
  final PackageInfo packageInfo;
  UpdateDialog(this.updateInfo, this.packageInfo);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 175,
                  width: double.infinity,
                  child: WaveWidget(
                    config: CustomConfig(
                      colors: [
//                    Colors.white70,
                        Colors.white54,
                        Colors.white30,
                        Colors.white,
                      ],
                      durations: [12000, 8000, 5000],
                      heightPercentages: [0.26, 0.28, 0.31],
//                  blur: MaskFilter.blur(BlurStyle.solid, 16.0),
                    ),
                    backgroundColor: CupertinoTheme.of(context).primaryColor,
                    size: Size(double.infinity, double.infinity),
                    waveAmplitude: 0,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 300,
                      height: 79,
                      child: Padding(
                        padding: EdgeInsets.only(left: 107.5, top: 8.5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "有更新啦!",
                              style: TextStyle(fontSize: 24, color: Color(0xffFFDFD8)),
                            ),
                            SizedBox(
                              height: 3.5,
                            ),
                            Text(
                              "V${packageInfo.version} build ${packageInfo.buildNumber} → V${updateInfo['version']} build ${updateInfo['build']}",
                              style: TextStyle(fontSize: 10, color: Color(0xffFFDFD8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Container(
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                        ),
                        padding: EdgeInsets.only(left: 23, right: 23, top: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "更新日志：",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14, height: 1.5),
                            ),
                            Text(
                              "${updateInfo['note']}",
                              style: TextStyle(color: Colors.black, fontSize: 14, height: 2),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: -25,
                left: 11,
                child: Image.asset(
                  "assets/icons/rocket.png",
                  width: 81.5,
                ),
              ),
              Positioned(
                bottom: 83,
                child: Container(
                  width: 300,
                  alignment: Alignment.center,
                  child: CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) {
                            return Update(updateInfo, direct: true);
                          },
                          settings: RouteSettings(name: "update")));
                    },
                    color: CupertinoTheme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(50),
                    minSize: 0,
                    padding: EdgeInsets.symmetric(horizontal: 29, vertical: 5),
                    child: Text(
                      "立即更新",
                      style: TextStyle(fontSize: 17.5, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: Container(
                  width: 300,
                  alignment: Alignment.center,
                  child: CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(50),
                    minSize: 0,
                    padding: EdgeInsets.symmetric(horizontal: 29, vertical: 5),
                    child: ImageIcon(
                      AssetImage("assets/icons/close.png"),
                      size: 48.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
