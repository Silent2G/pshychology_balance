import 'package:flutter/material.dart';

/// A clean, line-style smiley face drawn as vector graphics (no image assets).
///
/// [level] 0..3 controls the expression on a 4-point scale:
///   0 = sad, 1 = slightly sad, 2 = slightly happy, 3 = happy.
/// By default each level uses its own soft mood colour; pass [color] to override
/// (e.g. white when shown on a filled/selected background).
class MoodFace extends StatelessWidget {
  final int level;
  final double size;
  final Color? color;

  const MoodFace({super.key, required this.level, this.size = 42, this.color});

  /// Soft mood ramp from "not about me" (sad) to "fully about me" (happy).
  static const List<Color> moodColors = [
    Color(0xFFE67C7C), // 0 - soft coral
    Color(0xFFE0A45C), // 1 - warm amber
    Color(0xFF7FB891), // 2 - soft green
    Color(0xFF4EA863), // 3 - green
  ];

  static Color colorForLevel(int level) => moodColors[level.clamp(0, 3)];

  @override
  Widget build(BuildContext context) {
    final l = level.clamp(0, 3);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MoodFacePainter(level: l, color: color ?? moodColors[l]),
      ),
    );
  }
}

class _MoodFacePainter extends CustomPainter {
  final int level;
  final Color color;

  _MoodFacePainter({required this.level, required this.color});

  // How much the mouth curves for each level (negative = frown, positive = smile).
  static const List<double> _curvature = [-0.9, -0.35, 0.35, 0.9];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final stroke = w * 0.075;
    final center = Offset(w / 2, w / 2);
    final radius = (w - stroke) / 2;

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    // Face outline
    canvas.drawCircle(center, radius, line);

    // Eyes (filled dots)
    final eyeRadius = w * 0.058;
    final eyeY = w * 0.40;
    final eyeOffsetX = w * 0.185;
    final eyePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(Offset(center.dx - eyeOffsetX, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(center.dx + eyeOffsetX, eyeY), eyeRadius, eyePaint);

    // Mouth (quadratic arc; curvature sets smile vs frown)
    final curvature = _curvature[level.clamp(0, 3)];
    final mouthHalfWidth = w * 0.21;
    final mouthY = w * 0.62;
    final control = Offset(center.dx, mouthY + curvature * w * 0.22);
    final mouth = Path()
      ..moveTo(center.dx - mouthHalfWidth, mouthY)
      ..quadraticBezierTo(control.dx, control.dy, center.dx + mouthHalfWidth, mouthY);
    canvas.drawPath(mouth, line);
  }

  @override
  bool shouldRepaint(covariant _MoodFacePainter old) => old.level != level || old.color != color;
}
