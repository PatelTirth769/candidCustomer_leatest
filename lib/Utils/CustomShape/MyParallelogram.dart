import 'package:flutter/material.dart';

class MyParallelogram extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    var path = Path();
    paint.color = Colors.pink;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 2.0;
    path.moveTo(size.width / 5, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 5, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
