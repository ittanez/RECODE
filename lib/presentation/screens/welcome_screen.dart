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
              colors: [
                AppTheme.background,
                AppTheme.primary.withOpacity(0.3),
                AppTheme.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
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
}
