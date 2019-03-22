import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BleSearchingIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BleSearchingIndicatorState();
}

class BleSearchingIndicatorState extends State<BleSearchingIndicator>
    with SingleTickerProviderStateMixin {
  Timer _timer;
  int _frameNumber = 0;
  int _framesCount = 3;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        _frameNumber = ++_frameNumber % _framesCount;
      });
    });
  }

  Widget _buildFrame(int frameNumber) {
    return LayoutBuilder(builder: (context, constraints) {
      double size = constraints.biggest.shortestSide;
      switch (frameNumber) {
        case 0:
          return Transform.translate(
            child: Icon(
              Icons.bluetooth,
              color: Colors.white,
              size: size,
            ),
            offset: Offset(-0.0835 * size, 0),
          );
        case 1:
          return Padding(
            padding: EdgeInsets.only(right: 0.25 * size),
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.bluetooth_searching,
                  color: Colors.white,
                  size: size,
                ),
              ),
            ),
          );
        case 2:
        default:
          return Icon(Icons.bluetooth_searching,
              color: Colors.white, size: size);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double size = constraints.biggest.shortestSide;
      return Center(
        child: SizedBox(
          child: _buildFrame(_frameNumber),
          width: size,
          height: size,
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
