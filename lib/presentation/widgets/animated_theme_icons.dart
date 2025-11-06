import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';

/// Animated Hypnotic Spiral Icon
class HypnoticSpiralIcon extends StatefulWidget {
  final double size;
  final bool isHovered;

  const HypnoticSpiralIcon({
    super.key,
    this.size = 48,
    this.isHovered = false,
  });

  @override
  State<HypnoticSpiralIcon> createState() => _HypnoticSpiralIconState();
}

class _HypnoticSpiralIconState extends State<HypnoticSpiralIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpiralPainter(
              progress: _controller.value,
              isHovered: widget.isHovered,
            ),
          );
        },
      ),
    );
  }
}

class _SpiralPainter extends CustomPainter {
  final double progress;
  final bool isHovered;

  _SpiralPainter({required this.progress, required this.isHovered});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw spiral with 3 turns
    final path = Path();
    const turns = 3;
    const pointsPerTurn = 50;

    for (int i = 0; i < turns * pointsPerTurn; i++) {
      final t = i / (turns * pointsPerTurn);
      final angle = t * turns * 2 * math.pi + (progress * 2 * math.pi);
      final radius = maxRadius * t;

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Gradient colors
    final colors = [
      AppTheme.azure,
      AppTheme.primary,
      AppTheme.secondary,
    ];

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withOpacity(isHovered ? 0.8 : 0.5);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SpiralPainter oldDelegate) => true;
}

/// Animated Sprouting Seed Icon
class SproutingSeedIcon extends StatefulWidget {
  final double size;
  final bool isHovered;

  const SproutingSeedIcon({
    super.key,
    this.size = 48,
    this.isHovered = false,
  });

  @override
  State<SproutingSeedIcon> createState() => _SproutingSeedIconState();
}

class _SproutingSeedIconState extends State<SproutingSeedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final growthProgress = Curves.easeInOut.transform(_controller.value);
          return CustomPaint(
            painter: _SproutPainter(
              progress: growthProgress,
              isHovered: widget.isHovered,
            ),
          );
        },
      ),
    );
  }
}

class _SproutPainter extends CustomPainter {
  final double progress;
  final bool isHovered;

  _SproutPainter({required this.progress, required this.isHovered});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);

    // Draw seed (base)
    final seedPaint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(isHovered ? 0.9 : 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height - 8),
        width: 12,
        height: 16,
      ),
      seedPaint,
    );

    // Draw stem growing
    if (progress > 0.2) {
      final stemPaint = Paint()
        ..color = AppTheme.emerald.withOpacity(isHovered ? 0.9 : 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final stemHeight = (size.height * 0.6) * math.min(1.0, (progress - 0.2) / 0.8);
      canvas.drawLine(
        Offset(center.dx, size.height - 8),
        Offset(center.dx, size.height - 8 - stemHeight),
        stemPaint,
      );

      // Draw leaves sprouting
      if (progress > 0.5) {
        final leafProgress = (progress - 0.5) / 0.5;
        final leafPaint = Paint()
          ..color = AppTheme.emerald.withOpacity(isHovered ? 0.8 : 0.6)
          ..style = PaintingStyle.fill;

        // Left leaf
        final leftLeafPath = Path();
        leftLeafPath.moveTo(center.dx, size.height - 8 - stemHeight * 0.5);
        leftLeafPath.quadraticBezierTo(
          center.dx - 15 * leafProgress,
          size.height - 8 - stemHeight * 0.4,
          center.dx - 10 * leafProgress,
          size.height - 8 - stemHeight * 0.6,
        );
        canvas.drawPath(leftLeafPath, leafPaint);

        // Right leaf
        final rightLeafPath = Path();
        rightLeafPath.moveTo(center.dx, size.height - 8 - stemHeight * 0.5);
        rightLeafPath.quadraticBezierTo(
          center.dx + 15 * leafProgress,
          size.height - 8 - stemHeight * 0.4,
          center.dx + 10 * leafProgress,
          size.height - 8 - stemHeight * 0.6,
        );
        canvas.drawPath(rightLeafPath, leafPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_SproutPainter oldDelegate) => true;
}

/// Animated Opening Lock Icon
class OpeningLockIcon extends StatefulWidget {
  final double size;
  final bool isHovered;

  const OpeningLockIcon({
    super.key,
    this.size = 48,
    this.isHovered = false,
  });

  @override
  State<OpeningLockIcon> createState() => _OpeningLockIconState();
}

class _OpeningLockIconState extends State<OpeningLockIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final openProgress = Curves.easeInOut.transform(_controller.value);
          return CustomPaint(
            painter: _LockPainter(
              progress: openProgress,
              isHovered: widget.isHovered,
            ),
          );
        },
      ),
    );
  }
}

class _LockPainter extends CustomPainter {
  final double progress;
  final bool isHovered;

  _LockPainter({required this.progress, required this.isHovered});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = AppTheme.gold.withOpacity(isHovered ? 0.9 : 0.6)
      ..style = PaintingStyle.fill;

    final shacklePaint = Paint()
      ..color = AppTheme.gold.withOpacity(isHovered ? 0.9 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Draw lock body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.65),
        width: size.width * 0.5,
        height: size.height * 0.4,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Draw keyhole
    final keyholePaint = Paint()
      ..color = AppTheme.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.6),
      3,
      keyholePaint,
    );

    // Draw shackle (opens with progress)
    final shackleOpenAngle = progress * math.pi / 3; // Open up to 60 degrees
    final shacklePath = Path();

    final centerX = size.width / 2;
    final startY = size.height * 0.45;
    final radius = size.width * 0.2;

    // Left side of shackle (rotates open)
    final leftX = centerX - radius * math.cos(shackleOpenAngle);
    final leftY = startY - radius * math.sin(shackleOpenAngle);

    shacklePath.moveTo(centerX - radius, startY);
    shacklePath.arcToPoint(
      Offset(leftX, leftY),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Right side stays fixed
    shacklePath.moveTo(centerX + radius, startY);
    shacklePath.arcToPoint(
      Offset(centerX, startY - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    canvas.drawPath(shacklePath, shacklePaint);
  }

  @override
  bool shouldRepaint(_LockPainter oldDelegate) => true;
}

/// Animated Dissolving Cloud Icon
class DissolvingCloudIcon extends StatefulWidget {
  final double size;
  final bool isHovered;

  const DissolvingCloudIcon({
    super.key,
    this.size = 48,
    this.isHovered = false,
  });

  @override
  State<DissolvingCloudIcon> createState() => _DissolvingCloudIconState();
}

class _DissolvingCloudIconState extends State<DissolvingCloudIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final dissolveProgress = Curves.easeInOut.transform(_controller.value);
          return CustomPaint(
            painter: _CloudPainter(
              progress: dissolveProgress,
              isHovered: widget.isHovered,
            ),
          );
        },
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double progress;
  final bool isHovered;

  _CloudPainter({required this.progress, required this.isHovered});

  @override
  void paint(Canvas canvas, Size size) {
    // Cloud dissolves by reducing opacity and increasing scatter
    final baseOpacity = isHovered ? 0.8 : 0.5;
    final opacity = baseOpacity * (1 - progress * 0.6);

    final cloudPaint = Paint()
      ..color = Colors.grey.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw cloud as multiple circles that scatter and fade
    final scatter = progress * 10;

    // Main body circles
    canvas.drawCircle(
      Offset(center.dx + scatter, center.dy),
      size.width * 0.25,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(center.dx - 6 - scatter, center.dy - 2),
      size.width * 0.2,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 6 + scatter, center.dy - 2),
      size.width * 0.2,
      cloudPaint,
    );

    // Smaller particles dissolving
    if (progress > 0.3) {
      final particlePaint = Paint()
        ..color = Colors.grey.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 5; i++) {
        final angle = (progress * 2 * math.pi) + (i * math.pi / 2.5);
        final distance = 15 + (progress * 15);
        final x = center.dx + distance * math.cos(angle);
        final y = center.dy + distance * math.sin(angle);

        canvas.drawCircle(
          Offset(x, y),
          2 - (progress * 1.5),
          particlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CloudPainter oldDelegate) => true;
}
