import 'package:flutter/material.dart';

/// Custom avatar widget for the profile screen
class HeartProfileIcon extends StatelessWidget {
  final double size;

  const HeartProfileIcon({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: HeartPainter(),
        ),
      ),
    );
  }
}

/// Custom painter to draw a heart shape
class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.orangeAccent
          ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    final Path path = Path();

    // Draw heart shape
    path.moveTo(width / 2, height / 5);

    // Top left curve
    path.cubicTo(width / 8, 0, -width / 4, height / 2, width / 2, height);

    // Top right curve
    path.cubicTo(
      width * 1.25,
      height / 2,
      width * 0.875,
      0,
      width / 2,
      height / 5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
