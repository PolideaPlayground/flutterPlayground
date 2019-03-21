import 'package:flutter/material.dart';

class HexPainter extends CustomPainter {
  const HexPainter({
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
  }) : super();

  final Color foregroundColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = backgroundColor;
    paint.strokeWidth = size.width * 0.5;
    paint.strokeJoin = StrokeJoin.round;
    paint.style = PaintingStyle.stroke;
    var path = Path();
    path.addPolygon([
      Offset(size.width * 0.25, size.height * 0.375),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.375),
      Offset(size.width * 0.75, size.height * 0.625),
      Offset(size.width * 0.5, size.height * 0.75),
      Offset(size.width * 0.25, size.height * 0.625)
    ], true);
    canvas.drawPath(path, paint);

    paint.color = foregroundColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.23),
        size.height * 0.08, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
