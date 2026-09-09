import 'package:flutter/material.dart';

class OfferAvailedParallelogram extends CustomPainter {
  final Color color;

  OfferAvailedParallelogram({this.color = Colors.pink});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    var path = Path();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 2.0;

    // path.moveTo(size.width / 5, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.85, size.height);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
