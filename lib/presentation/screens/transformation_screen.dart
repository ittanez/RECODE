import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/texts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/submodality.dart';
import '../../domain/use_cases/transformation_state.dart';
import '../widgets/hypnotic_text.dart';
import 'feedback_screen.dart';

class TransformationScreen extends ConsumerStatefulWidget {
  const TransformationScreen({super.key});

  @override
  ConsumerState<TransformationScreen> createState() => _TransformationScreenState();
}

class _TransformationScreenState extends ConsumerState<TransformationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentPhaseIndex = 0;
  late Submodality _originalSubmodality;
  late Submodality _transformedSubmodality;

  final List<String> _phases = ['recognition', 'dissociation', 'transformation', 'integration'];
  final List<Duration> _phaseDurations = [
    const Duration(seconds: 15),
    const Duration(seconds: 20),
    const Duration(seconds: 25),
    const Duration(seconds: 20),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80), // Total duration
    );

    _originalSubmodality = ref.read(transformationProvider).currentSubmodality;
    _transformedSubmodality = _createTransformedSubmodality();

    _startTransformationSequence();
  }

  Submodality _createTransformedSubmodality() {
    // Transform to more resourceful state
    return _originalSubmodality.copyWith(
      distance: 0.7, // More distant = less intense
      brightness: 0.8, // Brighter = more positive
      size: 0.4, // Smaller = less overwhelming
      colorValue: AppTheme.emerald.value, // Resource color
      clarity: 0.6, // Slightly softer
      soundLevel: 'soft',
    );
  }

  void _startTransformationSequence() async {
    int totalSeconds = 0;
    for (int i = 0; i < _phases.length; i++) {
      await Future.delayed(_phaseDurations[i]);
      if (mounted) {
        setState(() {
          _currentPhaseIndex = i < _phases.length - 1 ? i + 1 : i;
        });
      }
    }

    // Navigate to anchor screen when complete
    if (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      _navigateToAnchor();
    }
  }

  void _navigateToAnchor() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FeedbackScreen(transformedSubmodality: _transformedSubmodality),
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

  double _getPhaseProgress() {
    final totalDuration = _phaseDurations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return _controller.value;
  }

  Submodality _getCurrentSubmodality() {
    final progress = _getPhaseProgress();
    return Submodality(
      distance: _originalSubmodality.distance +
          ((_transformedSubmodality.distance - _originalSubmodality.distance) * progress),
      brightness: _originalSubmodality.brightness +
          ((_transformedSubmodality.brightness - _originalSubmodality.brightness) * progress),
      size: _originalSubmodality.size +
          ((_transformedSubmodality.size - _originalSubmodality.size) * progress),
      colorValue: progress < 0.5
          ? _originalSubmodality.colorValue
          : _transformedSubmodality.colorValue,
      clarity: _originalSubmodality.clarity +
          ((_transformedSubmodality.clarity - _originalSubmodality.clarity) * progress),
      soundLevel: _transformedSubmodality.soundLevel,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background,
              AppTheme.secondary.withOpacity(0.3),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final currentSubmodality = _getCurrentSubmodality();
              return Stack(
                children: [
                  // Animated visual representation
                  Center(
                    child: _TransformationVisual(
                      submodality: currentSubmodality,
                      phase: _phases[_currentPhaseIndex],
                    ),
                  ),

                  // Phase text
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1000),
                        child: HypnoticText(
                          key: ValueKey(_currentPhaseIndex),
                          text: HypnoticTexts.transformationPhases[_phases[_currentPhaseIndex]]![0],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TransformationVisual extends StatelessWidget {
  final Submodality submodality;
  final String phase;

  const _TransformationVisual({
    required this.submodality,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate visual properties from submodality
    final size = 100 + (submodality.size * 200);
    final opacity = submodality.brightness;
    final blur = (1 - submodality.clarity) * 15;

    // Scale based on distance (further = smaller)
    final scale = 1.5 - (submodality.distance * 0.8);

    return Transform.scale(
      scale: scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(submodality.colorValue).withOpacity(opacity),
                  Color(submodality.colorValue).withOpacity(opacity * 0.5),
                  Color(submodality.colorValue).withOpacity(0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(submodality.colorValue).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
