import 'package:flutter/material.dart';

Widget get logo => CustomPaint(
  size: const Size(100, 32),
  painter: LogoPainter(),
);

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink[900]!
      ..style = PaintingStyle.fill;

    // Draw a stylized "CM" for Camora
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.4, 0)
      ..quadraticBezierTo(size.width * 0.6, 0, size.width * 0.6, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.6, size.width * 0.4, size.height * 0.6)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.2, size.height)
      ..close();

    // Draw the S part
    final sPath = Path()
      ..moveTo(size.width * 0.7, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.8, 0, size.width, 0)
      ..lineTo(size.width, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width * 0.8, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..quadraticBezierTo(size.width * 0.8, size.height, size.width * 0.7, size.height * 0.8)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(sPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
