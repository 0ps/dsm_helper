import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SoftButton extends StatefulWidget {
  @override
  _SoftButtonState createState() => _SoftButtonState();
}

class _SoftButtonState extends State<SoftButton> with SingleTickerProviderStateMixin {
  static const Duration kFadeOutDuration = Duration(milliseconds: 10);
  static const Duration kFadeInDuration = Duration(milliseconds: 100);
  AnimationController _animationController;
  Animation<double> _letterSpaceAnimation;
  bool _buttonHeldDown = false;
  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _letterSpaceAnimation = Tween(begin: 2.0, end: 0.1).animate(_animationController)
      ..addListener(() {
        setState(() {});
        print(_letterSpaceAnimation.value);
      });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController = null;
    super.dispose();
  }

  void _animate() {
    if (_animationController.isAnimating) return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown ? _animationController.animateTo(1.0, duration: kFadeInDuration) : _animationController.animateTo(0.0, duration: kFadeInDuration);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      onTapDown: (detail) {
        setState(() {
          if (!_buttonHeldDown) {
            _buttonHeldDown = true;
            _animate();
          }
        });
      },
      onTapUp: (detail) {
        setState(() {
          if (_buttonHeldDown) {
            _buttonHeldDown = false;
            _animate();
          }
        });
      },
      onTapCancel: () {
        setState(() {
          if (_buttonHeldDown) {
            _buttonHeldDown = false;
            _animate();
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: 300,
        height: 100,
        alignment: Alignment.center,
        // duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(50),
          boxShadow: _buttonHeldDown
              ? null
              : [
                  BoxShadow(
                    color: Color(0xffcfcfcf),
                    offset: Offset(-30, 30),
                    blurRadius: 60,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(30, -30),
                    blurRadius: 60,
                  ),
                ],
        ),
        child: Text(
          "测试按钮",
          style: TextStyle(
            fontSize: 24,
            // letterSpacing: _letterSpaceAnimation.value,
          ),
        ),
      ),
    );
  }
}
