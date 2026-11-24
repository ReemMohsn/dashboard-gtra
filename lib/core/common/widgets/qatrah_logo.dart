import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';

class QatrahLogo extends StatelessWidget {
  const QatrahLogo({
    super.key,
    this.size = 30,
    this.color = AppColor.primary,
    this.innerColor = AppColor.surface,
  });

  final double size;
  final Color color;
  final Color innerColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _QatrahDropPainter(color: color, innerColor: innerColor),
      ),
    );
  }
}

class _QatrahDropPainter extends CustomPainter {
  const _QatrahDropPainter({required this.color, required this.innerColor});

  final Color color;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final dropPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..cubicTo(w * 0.72, h * 0.34, w * 0.88, h * 0.50, w * 0.88, h * 0.66)
      ..cubicTo(w * 0.88, h * 0.86, w * 0.71, h * 0.96, w * 0.5, h * 0.96)
      ..cubicTo(w * 0.29, h * 0.96, w * 0.12, h * 0.86, w * 0.12, h * 0.66)
      ..cubicTo(w * 0.12, h * 0.50, w * 0.28, h * 0.34, w * 0.5, h * 0.04)
      ..close();

    canvas.drawPath(path, dropPaint);

    final ringCenter = Offset(w * 0.5, h * 0.64);
    final ringPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..isAntiAlias = true;

    canvas.drawCircle(ringCenter, w * 0.18, ringPaint);

    final centerDotPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(ringCenter, w * 0.065, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _QatrahDropPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.innerColor != innerColor;
  }
}
