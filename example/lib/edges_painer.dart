import 'package:dscan/dscan.dart';
import 'package:flutter/material.dart';

class EdgesPainter extends CustomPainter {
  const EdgesPainter(this.documentPoints);

  final List<DocPoint> documentPoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (documentPoints.length != 4) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 40.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(documentPoints[0].x, documentPoints[0].y);

    path.lineTo(documentPoints[1].x, documentPoints[1].y);
    path.lineTo(documentPoints[2].x, documentPoints[2].y);
    path.lineTo(documentPoints[3].x, documentPoints[3].y);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EdgesPainter old) => old.documentPoints != documentPoints;
}
