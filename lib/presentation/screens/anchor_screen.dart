import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class _AnchorScreenState extends ConsumerState<AnchorScreen> {
  int _anchorCount = 0;
  final int _maxAnchors = 3;
  bool _showInstructions = true;

  void _performAnchor(Offset position) {
    if (_anchorCount < _maxAnchors) {
      HapticFeedback.mediumImpact();
      setState(() {
        _anchorCount++;
      });

      if (_anchorCount >= _maxAnchors) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _navigateToJournal();
          }
        });
      }
    }
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
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  HypnoticTexts.anchorInstructions[0],
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 1000.ms)
                    .slideY(begin: -0.2, end: 0),
              ),

              const SizedBox(height: 24),

              // Instructions
              if (_showInstructions)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Posez deux doigts sur le cercle ci-dessous.\nRépétez ce geste 3 fois.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 1000.ms, delay: 500.ms),
                ),

              const Spacer(),

              // Anchor area
              GestureDetector(
                onTapDown: (details) {
                  _performAnchor(details.localPosition);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.gold.withOpacity(0.0),
                            AppTheme.gold.withOpacity(0.1),
                            AppTheme.gold.withOpacity(_anchorCount > 0 ? 0.3 : 0.0),
                          ],
                        ),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 2000.ms)
                        .then()
                        .fadeOut(duration: 2000.ms),

                    // Main circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.gold.withOpacity(0.6),
                            AppTheme.emerald.withOpacity(0.4),
                            AppTheme.azure.withOpacity(0.2),
                          ],
                        ),
                        border: Border.all(
                          color: AppTheme.gold,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _anchorCount >= _maxAnchors ? Icons.check : Icons.touch_app,
                          size: 60,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Counter
              Text(
                '$_anchorCount / $_maxAnchors',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.gold,
                      fontSize: 32,
                    ),
              ),

              const Spacer(),

              // Completion message
              if (_anchorCount >= _maxAnchors)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    HypnoticTexts.anchorInstructions[1],
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 1000.ms)
                      .slideY(begin: 0.2, end: 0),
                ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
