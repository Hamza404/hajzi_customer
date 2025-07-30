import 'package:flutter/material.dart';

class CustomMapPin extends StatelessWidget {
  final String topText;
  final String bottomText;
  final Color color;

  const CustomMapPin({
    Key? key,
    required this.topText,
    required this.bottomText,
    this.color = Colors.orange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: 80,
        height: 100,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pin shape
            CustomPaint(
              size: const Size(80, 100),
              painter: PinPainter(color: color),
            ),
            // Text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  topText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  bottomText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PinPainter extends CustomPainter {
  final Color color;

  PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    final double circleRadius = size.width / 2;
    final center = Offset(size.width / 2, circleRadius);

    // Draw circle
    canvas.drawCircle(center, circleRadius, paint);

    // Draw pointer triangle
    final Path path = Path()
      ..moveTo(size.width / 2 - 10, circleRadius + 5)
      ..lineTo(size.width / 2 + 10, circleRadius + 5)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}