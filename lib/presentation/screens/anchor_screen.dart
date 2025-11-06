import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import '../../core/constants/texts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/submodality.dart';
import 'journal_screen.dart';

class AnchorScreen extends ConsumerStatefulWidget {
  final Submodality transformedSubmodality;

  const AnchorScreen({
    super.key,
    required this.transformedSubmodality,
  });

  @override
  ConsumerState<AnchorScreen> createState() => _AnchorScreenState();
}

enum GestureType { circle, heart, infinity }

class _AnchorScreenState extends ConsumerState<AnchorScreen> {
  GestureType? _selectedGesture;
  int _anchorCount = 0;
  final int _maxAnchors = 3;
  List<Offset> _currentPath = [];
  bool _isDrawing = false;

  void _onGestureStart(Offset position) {
    setState(() {
      _isDrawing = true;
      _currentPath = [position];
    });
  }

  void _onGestureUpdate(Offset position) {
    if (_isDrawing) {
      setState(() {
        _currentPath.add(position);
      });

      // Haptic feedback every 10 points for continuous feedback
      if (_currentPath.length % 10 == 0) {
        _triggerHaptic();
      }
    }
  }

  Future<void> _triggerHaptic() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 20);
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _onGestureEnd() {
    if (_isDrawing && _currentPath.length > 10) {
      // Validate gesture
      if (_validateGesture()) {
        HapticFeedback.mediumImpact();
        setState(() {
          _anchorCount++;
          _isDrawing = false;
          _currentPath = [];
        });

        if (_anchorCount >= _maxAnchors) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _navigateToJournal();
            }
          });
        }
      } else {
        // Invalid gesture - shake feedback
        HapticFeedback.heavyImpact();
        setState(() {
          _currentPath = [];
          _isDrawing = false;
        });
      }
    } else {
      setState(() {
        _currentPath = [];
        _isDrawing = false;
      });
    }
  }

  bool _validateGesture() {
    // Simple validation: just check if path has enough points
    // In a real implementation, you'd do shape recognition
    return _currentPath.length > 15;
  }

  void _navigateToJournal() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            JournalScreen(transformedSubmodality: widget.transformedSubmodality),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background,
              AppTheme.primary.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: _selectedGesture == null ? _buildGestureSelection() : _buildDrawingArea(),
        ),
      ),
    );
  }

  Widget _buildGestureSelection() {
    return Column(
      children: [
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Choisissez votre geste d\'ancrage',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 1000.ms),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Ce geste sera votre point d\'ancrage pour retrouver cet état',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 1000.ms, delay: 300.ms),
        ),
        const Spacer(),
        _GestureOption(
          type: GestureType.circle,
          label: 'Cercle',
          description: 'Un mouvement circulaire, symbole de continuité',
          onTap: () => setState(() => _selectedGesture = GestureType.circle),
        ),
        const SizedBox(height: 24),
        _GestureOption(
          type: GestureType.heart,
          label: 'Cœur',
          description: 'Un cœur, symbole d\'amour et de bienveillance',
          onTap: () => setState(() => _selectedGesture = GestureType.heart),
        ),
        const SizedBox(height: 24),
        _GestureOption(
          type: GestureType.infinity,
          label: 'Infini',
          description: 'Le symbole infini, représentant l\'éternité',
          onTap: () => setState(() => _selectedGesture = GestureType.infinity),
        ),
        const Spacer(),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildDrawingArea() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Tracez votre geste',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Répétez le geste 3 fois lentement\nSentez la connexion se créer',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        // Counter
        Text(
          '$_anchorCount / $_maxAnchors',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.gold,
                fontSize: 32,
              ),
        ),
        const SizedBox(height: 32),
        // Drawing area
        Expanded(
          child: GestureDetector(
            onPanStart: (details) => _onGestureStart(details.localPosition),
            onPanUpdate: (details) => _onGestureUpdate(details.localPosition),
            onPanEnd: (_) => _onGestureEnd(),
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.gold.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                painter: _GesturePainter(
                  path: _currentPath,
                  gestureType: _selectedGesture!,
                  isDrawing: _isDrawing,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        if (_anchorCount >= _maxAnchors)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Text(
              'Votre ancrage est créé ✨',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.gold,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 1000.ms)
                .slideY(begin: 0.2, end: 0),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _GestureOption extends StatelessWidget {
  final GestureType type;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _GestureOption({
    required this.type,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withOpacity(0.3),
              AppTheme.secondary.withOpacity(0.2),
            ],
          ),
          border: Border.all(
            color: AppTheme.gold.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withOpacity(0.2),
              ),
              child: CustomPaint(
                painter: _GestureIconPainter(type: type),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0),
    );
  }
}

class _GestureIconPainter extends CustomPainter {
  final GestureType type;

  _GestureIconPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gold.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    switch (type) {
      case GestureType.circle:
        canvas.drawCircle(center, radius, paint);
        break;
      case GestureType.heart:
        _drawHeart(canvas, size, paint);
        break;
      case GestureType.infinity:
        _drawInfinity(canvas, size, paint);
        break;
    }
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, h * 0.7);
    path.cubicTo(w * 0.2, h * 0.5, w * 0.2, h * 0.2, w * 0.5, h * 0.35);
    path.cubicTo(w * 0.8, h * 0.2, w * 0.8, h * 0.5, w * 0.5, h * 0.7);

    canvas.drawPath(path, paint);
  }

  void _drawInfinity(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final centerY = h * 0.5;

    // Left loop
    path.moveTo(w * 0.3, centerY);
    path.cubicTo(w * 0.15, centerY - h * 0.2, w * 0.15, centerY + h * 0.2, w * 0.3, centerY);

    // Right loop
    path.moveTo(w * 0.7, centerY);
    path.cubicTo(w * 0.85, centerY + h * 0.2, w * 0.85, centerY - h * 0.2, w * 0.7, centerY);

    // Connect
    path.moveTo(w * 0.3, centerY);
    path.lineTo(w * 0.7, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GesturePainter extends CustomPainter {
  final List<Offset> path;
  final GestureType gestureType;
  final bool isDrawing;

  _GesturePainter({
    required this.path,
    required this.gestureType,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw guide shape
    final guidePaint = Paint()
      ..color = AppTheme.gold.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    _drawGuideShape(canvas, size, guidePaint);

    // Draw user path
    if (path.length > 1) {
      final pathPaint = Paint()
        ..color = AppTheme.emerald
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final drawnPath = Path();
      drawnPath.moveTo(path.first.dx, path.first.dy);

      for (int i = 1; i < path.length; i++) {
        drawnPath.lineTo(path[i].dx, path[i].dy);
      }

      canvas.drawPath(drawnPath, pathPaint);

      // Draw glow effect
      final glowPaint = Paint()
        ..color = AppTheme.emerald.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawPath(drawnPath, glowPaint);
    }
  }

  void _drawGuideShape(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;

    switch (gestureType) {
      case GestureType.circle:
        canvas.drawCircle(center, radius, paint);
        break;
      case GestureType.heart:
        _drawHeartGuide(canvas, size, paint);
        break;
      case GestureType.infinity:
        _drawInfinityGuide(canvas, size, paint);
        break;
    }
  }

  void _drawHeartGuide(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, h * 0.6);
    path.cubicTo(w * 0.25, h * 0.45, w * 0.25, h * 0.25, w * 0.5, h * 0.35);
    path.cubicTo(w * 0.75, h * 0.25, w * 0.75, h * 0.45, w * 0.5, h * 0.6);

    canvas.drawPath(path, paint);
  }

  void _drawInfinityGuide(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final centerY = h * 0.5;
    final loopRadius = w * 0.15;

    // Left loop
    path.addOval(Rect.fromCenter(
      center: Offset(w * 0.35, centerY),
      width: loopRadius * 2,
      height: loopRadius * 1.5,
    ));

    // Right loop
    path.addOval(Rect.fromCenter(
      center: Offset(w * 0.65, centerY),
      width: loopRadius * 2,
      height: loopRadius * 1.5,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GesturePainter oldDelegate) {
    return path != oldDelegate.path || isDrawing != oldDelegate.isDrawing;
  }
}
