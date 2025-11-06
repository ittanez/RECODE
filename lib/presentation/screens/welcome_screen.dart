import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import '../../core/constants/texts.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/hypnotic_text.dart';
import 'theme_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  bool _showContinueHint = false;
  bool _lastWasInhale = true;
  String _currentAmbiance = 'ocean'; // ocean, forest, dawn
  bool _eyesClosed = false;
  int _breathCycle = 0;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // 4s in + 4s out
    )..repeat(reverse: true);

    // Listen for breathing phase changes to trigger haptic feedback
    _breathController.addListener(() {
      // Detect when we start exhaling (value crosses 0.5 going down)
      if (_breathController.value < 0.5 && _lastWasInhale) {
        _lastWasInhale = false;
        _triggerExhalationHaptic();
        setState(() {
          _breathCycle++;
          // Suggest closing eyes after 2nd breath, opening after 4th
          if (_breathCycle == 2) {
            _eyesClosed = true;
          } else if (_breathCycle == 4) {
            _eyesClosed = false;
          }
        });
      } else if (_breathController.value >= 0.5 && !_lastWasInhale) {
        _lastWasInhale = true;
      }
    });

    // Show continue hint after sequence completes
    Future.delayed(const Duration(seconds: 24), () {
      if (mounted) {
        setState(() {
          _showContinueHint = true;
        });
      }
    });
  }

  Future<void> _triggerExhalationHaptic() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Gentle pulse: 50ms vibration
      Vibration.vibrate(duration: 50);
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  void _navigateNext() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ThemeSelectionScreen(),
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

  List<Color> _getAmbianceColors() {
    switch (_currentAmbiance) {
      case 'ocean':
        return [
          const Color(0xFF0D1117), // Deep night
          const Color(0xFF1A237E).withOpacity(0.4), // Deep blue
          const Color(0xFF006994).withOpacity(0.3), // Ocean
        ];
      case 'forest':
        return [
          const Color(0xFF0D1117),
          const Color(0xFF1B5E20).withOpacity(0.4), // Forest green
          const Color(0xFF2E7D32).withOpacity(0.3),
        ];
      case 'dawn':
        return [
          const Color(0xFF1A1A2E), // Pre-dawn
          const Color(0xFF4A148C).withOpacity(0.4), // Purple
          const Color(0xFFFF6F00).withOpacity(0.2), // Dawn orange
        ];
      default:
        return [
          AppTheme.background,
          AppTheme.primary.withOpacity(0.3),
          AppTheme.background,
        ];
    }
  }

  String _getEyesGuidance() {
    if (_breathCycle < 2) {
      return '';
    } else if (_breathCycle == 2) {
      return 'Si vous le souhaitez... fermez doucement les yeux';
    } else if (_breathCycle >= 4 && _breathCycle < 5) {
      return 'Vous pouvez rouvrir les yeux... en douceur';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final eyesGuidance = _getEyesGuidance();

    return Scaffold(
      body: GestureDetector(
        onTap: _navigateNext,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getAmbianceColors(),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Ambiance selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAmbianceButton('ocean', '🌊'),
                      const SizedBox(width: 16),
                      _buildAmbianceButton('forest', '🌲'),
                      const SizedBox(width: 16),
                      _buildAmbianceButton('dawn', '🌅'),
                    ],
                  ),
                ).animate().fadeIn(duration: 2000.ms),
                const Spacer(flex: 2),

                // Logo / Title
                Text(
                  'ReCode',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 8,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 2000.ms)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Transformez votre réalité intérieure en silence',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 2000.ms, delay: 500.ms),

                const Spacer(flex: 1),

                // Breathing animation
                AnimatedBuilder(
                  animation: _breathController,
                  builder: (context, child) {
                    final value = Curves.easeInOut.transform(_breathController.value);
                    return Container(
                      width: 120 + (value * 40),
                      height: 120 + (value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.azure.withOpacity(0.6 + (value * 0.2)),
                            AppTheme.primary.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),

                // Eyes guidance
                if (eyesGuidance.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                    child: Text(
                      eyesGuidance,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.gold.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 2000.ms)
                        .then(delay: 8000.ms)
                        .fadeOut(duration: 2000.ms),
                  ),

                // Hypnotic texts
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: SequentialHypnoticTexts(
                    texts: HypnoticTexts.inductionTexts,
                    intervalBetweenTexts: Duration(seconds: 4),
                  ),
                ),

                const Spacer(flex: 2),

                // Continue hint
                if (_showContinueHint)
                  Text(
                    'Touchez l\'écran pour continuer',
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: 1000.ms)
                      .then()
                      .fadeOut(duration: 1000.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbianceButton(String ambiance, String emoji) {
    final isSelected = _currentAmbiance == ambiance;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentAmbiance = ambiance;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppTheme.primary.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: isSelected ? 24 : 20),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(duration: 300.ms);
  }
}
