import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/submodality.dart';
import 'anchor_screen.dart';

/// Écran 3.5.0 : Feedback Post-Transformation
/// Affiche "LE CODE EST MODIFIÉ ✨" avec vibration longue
/// Durée : 5 secondes
class FeedbackScreen extends StatefulWidget {
  final Submodality transformedSubmodality;

  const FeedbackScreen({
    super.key,
    required this.transformedSubmodality,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation fade: 1s in → 3s stable → 1s out = 5s total
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _fadeAnimation = TweenSequence<double>([
      // Fade in : 0 → 1 (1s)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20, // 20% of 5s = 1s
      ),
      // Stable : 1 (3s)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60, // 60% of 5s = 3s
      ),
      // Fade out : 1 → 0 (1s)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20, // 20% of 5s = 1s
      ),
    ]).animate(_controller);

    _controller.forward();

    // Vibration longue au démarrage
    _triggerLongVibration();

    // Navigation automatique après 5s
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _navigateToAnchor();
      }
    });
  }

  Future<void> _triggerLongVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Vibration longue : 500ms
      Vibration.vibrate(duration: 500);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _navigateToAnchor() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AnchorScreen(transformedSubmodality: widget.transformedSubmodality),
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
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              AppTheme.secondary.withOpacity(0.4), // Violet profond
              AppTheme.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cercle transformé (état final)
              _buildTransformedCircle(),

              const SizedBox(height: 80),

              // Message principal animé
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'LE CODE EST MODIFIÉ ✨',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                        letterSpacing: 3,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransformedCircle() {
    // Affiche le cercle dans son état transformé final
    // (petit, éloigné, émeraude, lumineux)
    final transformedColor = Color(widget.transformedSubmodality.colorValue);

    // Distance: 0.7 → cercle petit et éloigné (100 + 30 = 130px)
    final circleSize = 200 - (widget.transformedSubmodality.distance * 100);

    // Brightness: 0.8 → lumineux
    final opacity = widget.transformedSubmodality.brightness;

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            transformedColor.withOpacity(opacity * 0.8),
            transformedColor.withOpacity(opacity * 0.5),
            transformedColor.withOpacity(opacity * 0.2),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: transformedColor.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
