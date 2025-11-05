import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/texts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/submodality.dart';
import '../../domain/use_cases/transformation_state.dart';
import '../widgets/submodality_slider.dart';
import 'transformation_screen.dart';

class ExplorationScreen extends ConsumerStatefulWidget {
  const ExplorationScreen({super.key});

  @override
  ConsumerState<ExplorationScreen> createState() => _ExplorationScreenState();
}

class _ExplorationScreenState extends ConsumerState<ExplorationScreen> {
  int _currentQuestionIndex = 0;
  late Submodality _workingSubmodality;

  final List<String> _questionKeys = [
    'distance',
    'brightness',
    'size',
    'color',
    'clarity',
    'sound',
  ];

  @override
  void initState() {
    super.initState();
    _workingSubmodality = Submodality.neutral();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questionKeys.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Save initial intensity
      _showIntensityDialog();
    }
  }

  void _showIntensityDialog() {
    int intensity = 5;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primary.withOpacity(0.9),
        title: Text(
          'Évaluation initiale',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sur une échelle de 0 à 10, quelle est l\'intensité de cette émotion/sensation maintenant ?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Slider(
                  value: intensity.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: intensity.toString(),
                  onChanged: (value) {
                    setDialogState(() {
                      intensity = value.toInt();
                    });
                  },
                ),
                Text(
                  intensity.toString(),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.gold,
                      ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(transformationProvider.notifier).updateIntensityBefore(intensity);
              ref.read(transformationProvider.notifier).updateSubmodality(_workingSubmodality);
              Navigator.of(context).pop();
              _navigateToTransformation();
            },
            child: const Text('Continuer', style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
  }

  void _navigateToTransformation() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TransformationScreen(),
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

  Widget _buildQuestionWidget(String questionKey) {
    switch (questionKey) {
      case 'distance':
        return SubmodalitySlider(
          question: HypnoticTexts.submodalityQuestions['distance']!,
          value: _workingSubmodality.distance,
          onChanged: (value) {
            setState(() {
              _workingSubmodality = _workingSubmodality.copyWith(distance: value);
            });
          },
          leftLabel: 'Proche',
          rightLabel: 'Éloigné',
          visualFeedback: _DistanceVisual(distance: _workingSubmodality.distance),
        );

      case 'brightness':
        return SubmodalitySlider(
          question: HypnoticTexts.submodalityQuestions['brightness']!,
          value: _workingSubmodality.brightness,
          onChanged: (value) {
            setState(() {
              _workingSubmodality = _workingSubmodality.copyWith(brightness: value);
            });
          },
          leftLabel: 'Sombre',
          rightLabel: 'Lumineux',
          visualFeedback: _BrightnessVisual(brightness: _workingSubmodality.brightness),
        );

      case 'size':
        return SubmodalitySlider(
          question: HypnoticTexts.submodalityQuestions['size']!,
          value: _workingSubmodality.size,
          onChanged: (value) {
            setState(() {
              _workingSubmodality = _workingSubmodality.copyWith(size: value);
            });
          },
          leftLabel: 'Petit',
          rightLabel: 'Grand',
          visualFeedback: _SizeVisual(size: _workingSubmodality.size),
        );

      case 'color':
        return ColorPicker(
          question: HypnoticTexts.submodalityQuestions['color']!,
          selectedColorValue: _workingSubmodality.colorValue,
          onColorSelected: (colorValue) {
            setState(() {
              _workingSubmodality = _workingSubmodality.copyWith(colorValue: colorValue);
            });
          },
        );

      case 'clarity':
        return SubmodalitySlider(
          question: HypnoticTexts.submodalityQuestions['clarity']!,
          value: _workingSubmodality.clarity,
          onChanged: (value) {
            setState(() {
              _workingSubmodality = _workingSubmodality.copyWith(clarity: value);
            });
          },
          leftLabel: 'Flou',
          rightLabel: 'Net',
          visualFeedback: _ClarityVisual(clarity: _workingSubmodality.clarity),
        );

      case 'sound':
        return _SoundSelector(
          currentLevel: _workingSubmodality.soundLevel,
          onChanged: (level) {
            setState(() {
              _workingSubmodality = _workingSubmodality.copyWith(soundLevel: level);
            });
          },
        );

      default:
        return const SizedBox.shrink();
    }
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
              AppTheme.secondary.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questionKeys.length,
                  backgroundColor: AppTheme.primary.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                ),
              ),

              const SizedBox(height: 48),

              // Question
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      key: ValueKey(_currentQuestionIndex),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _buildQuestionWidget(_questionKeys[_currentQuestionIndex]),
                    ),
                  ),
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestionIndex < _questionKeys.length - 1
                        ? 'Suivant'
                        : 'Transformer',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Visual feedback widgets
class _DistanceVisual extends StatelessWidget {
  final double distance;
  const _DistanceVisual({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100 + (distance * 50),
        height: 100 + (distance * 50),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.azure.withOpacity(0.3 - (distance * 0.2)),
        ),
      ),
    );
  }
}

class _BrightnessVisual extends StatelessWidget {
  final double brightness;
  const _BrightnessVisual({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.azure.withOpacity(brightness),
        ),
      ),
    );
  }
}

class _SizeVisual extends StatelessWidget {
  final double size;
  const _SizeVisual({required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 50 + (size * 120),
        height: 50 + (size * 120),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.emerald.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _ClarityVisual extends StatelessWidget {
  final double clarity;
  const _ClarityVisual({required this.clarity});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: (1 - clarity) * 10,
            sigmaY: (1 - clarity) * 10,
          ),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppTheme.gold.withOpacity(0.5),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 60, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundSelector extends StatelessWidget {
  final String currentLevel;
  final ValueChanged<String> onChanged;

  const _SoundSelector({
    required this.currentLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Text(
            HypnoticTexts.submodalityQuestions['sound']!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SoundButton(
              label: 'Silencieux',
              value: 'silent',
              isSelected: currentLevel == 'silent',
              onTap: () => onChanged('silent'),
            ),
            _SoundButton(
              label: 'Doux',
              value: 'soft',
              isSelected: currentLevel == 'soft',
              onTap: () => onChanged('soft'),
            ),
            _SoundButton(
              label: 'Fort',
              value: 'loud',
              isSelected: currentLevel == 'loud',
              onTap: () => onChanged('loud'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SoundButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppTheme.gold.withOpacity(0.3)
              : AppTheme.primary.withOpacity(0.2),
          border: Border.all(
            color: isSelected ? AppTheme.gold : AppTheme.primary.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.gold : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
