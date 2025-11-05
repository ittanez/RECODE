import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/texts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/submodality.dart';
import '../../data/models/transformation.dart';
import '../../data/repositories/transformation_repository.dart';
import '../../domain/use_cases/transformation_state.dart';
import 'welcome_screen.dart';

class JournalScreen extends ConsumerStatefulWidget {
  final Submodality transformedSubmodality;

  const JournalScreen({
    super.key,
    required this.transformedSubmodality,
  });

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _noteController = TextEditingController();
  int _intensityAfter = 5;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveAndFinish() async {
    setState(() {
      _isSaving = true;
    });

    final state = ref.read(transformationProvider);
    final repository = ref.read(transformationRepositoryProvider);

    final transformation = Transformation(
      date: DateTime.now().toIso8601String(),
      theme: state.theme ?? 'unknown',
      intensityBefore: state.intensityBefore,
      intensityAfter: _intensityAfter,
      userNote: _noteController.text.isNotEmpty ? _noteController.text : null,
      submodalitiesBefore: state.currentSubmodality,
      submodalitiesAfter: widget.transformedSubmodality,
    );

    await repository.insertTransformation(transformation);

    // Reset state
    ref.read(transformationProvider.notifier).reset();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transformationProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background,
              AppTheme.emerald.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Title
                Text(
                  'Transformation complétée',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 1000.ms)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: 8),

                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppTheme.emerald,
                )
                    .animate()
                    .scale(duration: 800.ms, delay: 300.ms),

                const SizedBox(height: 48),

                // Intensity comparison
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.primary.withOpacity(0.2),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        HypnoticTexts.closureQuestion,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Slider(
                        value: _intensityAfter.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: _intensityAfter.toString(),
                        onChanged: (value) {
                          setState(() {
                            _intensityAfter = value.toInt();
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _intensityAfter.toString(),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppTheme.gold,
                                  fontSize: 48,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _IntensityComparison(
                        before: state.intensityBefore,
                        after: _intensityAfter,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Journal note
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.primary.withOpacity(0.2),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        HypnoticTexts.journalPrompt,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        maxLines: 5,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Écrivez vos réflexions ici...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textCaption,
                              ),
                          filled: true,
                          fillColor: AppTheme.background.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndFinish,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: AppTheme.emerald,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Terminer',
                          style: TextStyle(fontSize: 18),
                        ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntensityComparison extends StatelessWidget {
  final int before;
  final int after;

  const _IntensityComparison({
    required this.before,
    required this.after,
  });

  @override
  Widget build(BuildContext context) {
    final improvement = before - after;
    final improvementPercent = before > 0 ? ((improvement / before) * 100).round() : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _IntensityIndicator(
              label: 'Avant',
              value: before,
              color: Colors.red,
            ),
            Icon(
              Icons.arrow_forward,
              color: AppTheme.gold,
              size: 32,
            ),
            _IntensityIndicator(
              label: 'Après',
              value: after,
              color: AppTheme.emerald,
            ),
          ],
        ),
        if (improvement > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppTheme.emerald.withOpacity(0.2),
            ),
            child: Text(
              '↓ -$improvement points (-$improvementPercent%)',
              style: TextStyle(
                color: AppTheme.emerald,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _IntensityIndicator extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _IntensityIndicator({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
