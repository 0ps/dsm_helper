import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

typedef CallBack = Function(int);

class NeuPicker extends StatefulWidget {
  final int value;
  final List data;
  final CallBack onConfirm;
  NeuPicker(this.data, {this.value: 0, this.onConfirm});
  @override
  _NeuPickerState createState() => _NeuPickerState();
}

class _NeuPickerState extends State<NeuPicker> {
  FixedExtentScrollController _controller;
  int value;
  @override
  void initState() {
    value = widget.value ?? 0;
    _controller = FixedExtentScrollController(initialItem: value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: NeuCard(
        height: 300,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 2,
        curveType: CurveType.concave,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  NeuButton(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    bevel: 10,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("取消"),
                  ),
                  Spacer(),
                  NeuButton(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    bevel: 10,
                    onPressed: () {
                      widget.onConfirm(value);
                      Navigator.of(context).pop();
                    },
                    child: Text("确定"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker.builder(
                itemBuilder: (context, i) {
                  return Text(widget.data[i]);
                },
                childCount: widget.data.length,
                scrollController: _controller,
                itemExtent: 40,
                onSelectedItemChanged: (v) => value = v,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
