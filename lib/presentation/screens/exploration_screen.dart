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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Text(
                HypnoticTexts.submodalityQuestions['distance']!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Faites glisser le cercle pour ajuster la distance',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.gold.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _InteractiveDistanceVisual(
                distance: _workingSubmodality.distance,
                onDistanceChanged: (value) {
                  setState(() {
                    _workingSubmodality = _workingSubmodality.copyWith(distance: value);
                  });
                },
              ),
            ),
          ],
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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Text(
                HypnoticTexts.submodalityQuestions['size']!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pincez pour ajuster la taille',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.gold.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _InteractiveSizeVisual(
                size: _workingSubmodality.size,
                onSizeChanged: (value) {
                  setState(() {
                    _workingSubmodality = _workingSubmodality.copyWith(size: value);
                  });
                },
              ),
            ),
          ],
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

// Interactive gesture-based widgets
class _InteractiveDistanceVisual extends StatefulWidget {
  final double distance;
  final ValueChanged<double> onDistanceChanged;

  const _InteractiveDistanceVisual({
    required this.distance,
    required this.onDistanceChanged,
  });

  @override
  State<_InteractiveDistanceVisual> createState() => _InteractiveDistanceVisualState();
}

class _InteractiveDistanceVisualState extends State<_InteractiveDistanceVisual> {
  double _dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxOffset = screenWidth * 0.35;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dy).clamp(-maxOffset, maxOffset);
          // Map drag offset to distance (0.0 to 1.0)
          // Dragging up (negative) = closer (0), dragging down (positive) = farther (1)
          final normalizedDistance = ((_dragOffset + maxOffset) / (maxOffset * 2)).clamp(0.0, 1.0);
          widget.onDistanceChanged(normalizedDistance);
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Guide text
            Positioned(
              top: 20,
              child: Text(
                widget.distance < 0.3 ? 'Proche' : widget.distance > 0.7 ? 'Éloigné' : 'Moyen',
                style: TextStyle(
                  color: AppTheme.gold.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Interactive circle
            Center(
              child: Container(
                width: 100 + (widget.distance * 50),
                height: 100 + (widget.distance * 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.azure.withOpacity(0.5 - (widget.distance * 0.3)),
                      AppTheme.primary.withOpacity(0.3 - (widget.distance * 0.2)),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.azure.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.touch_app,
                    size: 40,
                    color: AppTheme.gold.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            // Distance indicator
            Positioned(
              bottom: 20,
              child: Text(
                '${(widget.distance * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveSizeVisual extends StatefulWidget {
  final double size;
  final ValueChanged<double> onSizeChanged;

  const _InteractiveSizeVisual({
    required this.size,
    required this.onSizeChanged,
  });

  @override
  State<_InteractiveSizeVisual> createState() => _InteractiveSizeVisualState();
}

class _InteractiveSizeVisualState extends State<_InteractiveSizeVisual> {
  double _baseSize = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _baseSize = (_baseSize * details.scale).clamp(0.5, 2.0);
          // Map scale to size (0.0 to 1.0)
          final normalizedSize = ((_baseSize - 0.5) / 1.5).clamp(0.0, 1.0);
          widget.onSizeChanged(normalizedSize);
        });
      },
      onScaleEnd: (details) {
        setState(() {
          _baseSize = 1.0;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Guide text
            Positioned(
              top: 20,
              child: Text(
                widget.size < 0.3 ? 'Petit' : widget.size > 0.7 ? 'Grand' : 'Moyen',
                style: TextStyle(
                  color: AppTheme.gold.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Interactive circle
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 50 + (widget.size * 120),
                height: 50 + (widget.size * 120),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.emerald.withOpacity(0.7),
                      AppTheme.emerald.withOpacity(0.4),
                      AppTheme.emerald.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.emerald.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.open_in_full,
                    size: 30 + (widget.size * 20),
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            // Size indicator
            Positioned(
              bottom: 20,
              child: Text(
                '${(widget.size * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
