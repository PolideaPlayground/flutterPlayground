import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BleSearchingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  BleSearchingIndicator({
    Key key,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    print(size);
    return BleSearchingIndicatorState(size: size, color: color);
  }
}

class BleSearchingIndicatorState extends State<BleSearchingIndicator>
    with SingleTickerProviderStateMixin {
  Timer _timer;
  int _frameNumber = 0;
  int _framesCount = 4;

  final Color color;
  final double size;

  BleSearchingIndicatorState({this.size, this.color});

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
      switch (frameNumber) {
        case 0:
          return Transform.translate(
            child: Icon(
              Icons.bluetooth,
              color: color,
              size: size,
            ),
            // Matches 'bluetooth' icon with 'bluetooth_searching' icon.
            offset: Offset(-0.0835 * (size ?? IconTheme.of(context).size), 0),
          );
        case 1:
          return ClipRect(
            // Removes the bigger wave shape.
            clipper: _BigWaveClipper(),
            child: Icon(
              Icons.bluetooth_searching,
              color: color,
              size: size,
            ),
          );
        case 2:
          return Icon(Icons.bluetooth_searching, color: color, size: size);
        case 3:
          // Removes the smaller wave shape.
          return ClipPath(
            clipper: _SmallWaveClipper(),
            child: Icon(
              Icons.bluetooth_searching,
              color: color,
              size: size,
            ),
          );
        default:
          return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: _buildFrame(_frameNumber),
      width: size,
      height: size,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}

class _BigWaveClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * 0.75, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class _SmallWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon([
      Offset(0, 0),
      Offset(size.width, 0),
      Offset(size.width, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.75),
      Offset(size.width * 0.75, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ], true);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
