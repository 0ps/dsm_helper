/*
 * 创建日期：23/12/19 下午 05:31
 * 版权所有：青岛人才在线企业服务管理有限公司
 */

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:neumorphic/neumorphic.dart';

class PreviewPage extends StatefulWidget {
  final List<String> images;
  final int index;
  final bool network;
  final PageController pageController;
  PreviewPage(this.images, this.index, {this.network = true}) : this.pageController = PageController(initialPage: index);

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  var rebuildIndex = StreamController<int>.broadcast();
  var rebuildSwiper = StreamController<bool>.broadcast();
  Function animationListener;
  bool _showSwiper = true;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  int currentIndex = 0;
  bool blackBackground = false;
  GlobalKey<ExtendedImageSlidePageState> slidePagekey = GlobalKey<ExtendedImageSlidePageState>();
  double initScale({Size imageSize, Size size, double initialScale}) {
    var n1 = imageSize.height / imageSize.width;
    var n2 = size.height / size.width;
    if (n1 > n2) {
      final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      Size destinationSize = fittedSizes.destination;
      return size.width / destinationSize.width;
    } else if (n1 / n2 < 1 / 4) {
      final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      Size destinationSize = fittedSizes.destination;
      return size.height / destinationSize.height;
    }

    return initialScale;
  }

  @override
  void initState() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    setState(() {
      currentIndex = widget.index;
    });
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void dispose() {
    rebuildIndex.close();
    rebuildSwiper.close();
    _animationController?.dispose();
    clearGestureDetailsCache();
    //cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget result = Material(
      color: Theme.of(context).scaffoldBackgroundColor == Colors.black ? Colors.black : Colors.transparent,
      shadowColor: Theme.of(context).scaffoldBackgroundColor == Colors.black ? Colors.black : Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ExtendedImageGesturePageView.builder(
            itemBuilder: (BuildContext context, int index) {
              var item = widget.images[index];
              Widget image;
              if (widget.network) {
                image = ExtendedImage.network(
                  item,
                  fit: BoxFit.contain,
                  enableSlideOutPage: true,
                  mode: ExtendedImageMode.gesture,
                  heroBuilderForSlidingPage: (Widget result) {
                    return Hero(
                      tag: item,
                      child: result,
                      flightShuttleBuilder: (BuildContext flightContext, Animation<double> animation, HeroFlightDirection flightDirection, BuildContext fromHeroContext, BuildContext toHeroContext) {
                        final Hero hero = flightDirection == HeroFlightDirection.pop ? fromHeroContext.widget : toHeroContext.widget;
                        return hero.child;
                      },
                    );
                  },
                  initGestureConfigHandler: (state) {
                    double initialScale = 1.0;
                    if (state.extendedImageInfo != null && state.extendedImageInfo.image != null) {
                      initialScale = initScale(size: size, initialScale: initialScale, imageSize: Size(state.extendedImageInfo.image.width.toDouble(), state.extendedImageInfo.image.height.toDouble()));
                    }
                    return GestureConfig(
                        inPageView: true,
                        initialScale: initialScale,
                        maxScale: max(initialScale, 5.0),
                        animationMaxScale: max(initialScale, 5.0),
                        //you can cache gesture state even though page view page change.
                        //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                        cacheGesture: false);
                  },
                  onDoubleTap: (ExtendedImageGestureState state) {
                    ///you can use define pointerDownPosition as you can,
                    ///default value is double tap pointer down postion.
                    var pointerDownPosition = state.pointerDownPosition;
                    double begin = state.gestureDetails.totalScale;
                    double end;
                    _animation?.removeListener(animationListener);
                    _animationController.stop();
                    _animationController.reset();
                    if (begin == doubleTapScales[0]) {
                      end = doubleTapScales[1];
                    } else {
                      end = doubleTapScales[0];
                    }
                    animationListener = () {
                      state.handleDoubleTap(scale: _animation.value, doubleTapPosition: pointerDownPosition);
                    };
                    _animation = _animationController.drive(Tween<double>(begin: begin, end: end));
                    _animation.addListener(animationListener);
                    _animationController.forward();
                  },
                );
              } else {
                image = ExtendedImage.file(
                  File(widget.images[index]),
                  fit: BoxFit.contain,
                  enableSlideOutPage: true,
                  mode: ExtendedImageMode.gesture,
                  heroBuilderForSlidingPage: (Widget result) {
                    return Hero(
                      tag: item,
                      child: result,
                      flightShuttleBuilder: (BuildContext flightContext, Animation<double> animation, HeroFlightDirection flightDirection, BuildContext fromHeroContext, BuildContext toHeroContext) {
                        final Hero hero = flightDirection == HeroFlightDirection.pop ? fromHeroContext.widget : toHeroContext.widget;
                        return hero.child;
                      },
                    );
                  },
                  initGestureConfigHandler: (state) {
                    double initialScale = 1.0;
                    if (state.extendedImageInfo != null && state.extendedImageInfo.image != null) {
                      initialScale = initScale(size: size, initialScale: initialScale, imageSize: Size(state.extendedImageInfo.image.width.toDouble(), state.extendedImageInfo.image.height.toDouble()));
                    }
                    return GestureConfig(
                        inPageView: true,
                        initialScale: initialScale,
                        maxScale: max(initialScale, 5.0),
                        animationMaxScale: max(initialScale, 5.0),
                        //you can cache gesture state even though page view page change.
                        //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                        cacheGesture: false);
                  },
                  onDoubleTap: (ExtendedImageGestureState state) {
                    ///you can use define pointerDownPosition as you can,
                    ///default value is double tap pointer down postion.
                    var pointerDownPosition = state.pointerDownPosition;
                    double begin = state.gestureDetails.totalScale;
                    double end;
                    _animation?.removeListener(animationListener);
                    _animationController.stop();
                    _animationController.reset();
                    if (begin == doubleTapScales[0]) {
                      end = doubleTapScales[1];
                    } else {
                      end = doubleTapScales[0];
                    }
                    animationListener = () {
                      state.handleDoubleTap(scale: _animation.value, doubleTapPosition: pointerDownPosition);
                    };
                    _animation = _animationController.drive(Tween<double>(begin: begin, end: end));
                    _animation.addListener(animationListener);
                    _animationController.forward();
                  },
                );
              }

              image = GestureDetector(
                child: image,
                onTap: () {
                  slidePagekey.currentState.popPage();
                  Navigator.pop(context);
                },
              );

              return image;
            },
            itemCount: widget.images.length,
            onPageChanged: (int index) {
              currentIndex = index;
              rebuildIndex.add(index);
            },
            controller: PageController(
              initialPage: currentIndex,
            ),
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
          ),
          StreamBuilder<bool>(
            builder: (c, d) {
              if (d.data == null || !d.data) return Container();

              return Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: MySwiperPlugin(widget.images, currentIndex, rebuildIndex),
              );
            },
            initialData: true,
            stream: rebuildSwiper.stream,
          )
        ],
      ),
    );

    result = ExtendedImageSlidePage(
      key: slidePagekey,
      child: result,
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      onSlidingPage: (state) {
        ///you can change other widgets' state on page as you want
        ///base on offset/isSliding etc
        //var offset= state.offset;
        var showSwiper = !state.isSliding;
        if (showSwiper != _showSwiper) {
          // do not setState directly here, the image state will change,
          // you should only notify the widgets which are needed to change
          // setState(() {
          // _showSwiper = showSwiper;
          // });

          _showSwiper = showSwiper;
          rebuildSwiper.add(_showSwiper);
        }
      },
    );

    return result;
  }
}

class MySwiperPlugin extends StatelessWidget {
  final List pics;
  final int index;
  final StreamController<int> reBuild;
  MySwiperPlugin(this.pics, this.index, this.reBuild);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      builder: (BuildContext context, data) {
        return DefaultTextStyle(
          style: TextStyle(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  NeuButton(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: () {
                      print(index);
                      Util.saveImage(pics[index], context: context).then((res) {
                        if (res['code'] == 1) {
                          Util.toast("已保存到相册");
                        } else {
                          Util.toast("图片下载失败");
                        }
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.file_download,
                          size: 13,
                        ),
                        Text(
                          " 保存图片",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: CurveType.flat,
                    bevel: 10,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "${data.data + 1} / ${pics.length}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      initialData: index,
      stream: reBuild.stream,
    );
  }
}
