import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import '../../core/constants/texts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/submodality.dart';
import '../../domain/use_cases/transformation_state.dart';
import '../widgets/submodality_slider.dart';
import 'transformation_screen.dart';

/// Phase d'exploration (Protocole YO/YF)
enum ExplorationPhase {
  manipulation, // Phase 1: Ajustement (Yeux Ouverts)
  integration,  // Phase 2: Ressenti (Yeux Fermés - pause 5-10s)
  validation,   // Phase 3: Confirmation (Yeux Ouverts)
}

class ExplorationScreen extends ConsumerStatefulWidget {
  const ExplorationScreen({super.key});

  @override
  ConsumerState<ExplorationScreen> createState() => _ExplorationScreenState();
}

class _ExplorationScreenState extends ConsumerState<ExplorationScreen> {
  int _currentQuestionIndex = 0;
  ExplorationPhase _currentPhase = ExplorationPhase.manipulation;
  late Submodality _workingSubmodality;
  bool _showIntroduction = true;
  bool _integrationTimerStarted = false;

  final List<String> _questionKeys = [
    'distance',
    'brightness',
    'size',
    'color',
    'clarity',
    'sound',
  ];

  final Map<String, String> _integrationInstructions = {
    'distance': 'Fermez les yeux. Observez l\'image ajustée. Prenez note de la sensation dans votre corps.',
    'brightness': 'Fermez les yeux. Ressentez la luminosité de cette image. Comment votre corps réagit-il ?',
    'size': 'Fermez les yeux. Ressentez la taille de cette image. Observez les sensations.',
    'color': 'Fermez les yeux. Ressentez cette couleur. Qu\'évoque-t-elle en vous ?',
    'clarity': 'Fermez les yeux. Ressentez la netteté de cette image. Comment vous sentez-vous ?',
    'sound': 'Fermez les yeux. Écoutez ce son intérieur. Observez vos sensations.',
  };

  @override
  void initState() {
    super.initState();
    _workingSubmodality = Submodality.neutral();
  }

  void _dismissIntroduction() {
    setState(() {
      _showIntroduction = false;
    });
  }

  void _startIntegrationPhase() {
    setState(() {
      _currentPhase = ExplorationPhase.integration;
      _integrationTimerStarted = false;
    });
  }

  void _startIntegrationTimer() {
    setState(() {
      _integrationTimerStarted = true;
    });

    // Timer de 8 secondes pour la phase d'intégration
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _currentPhase == ExplorationPhase.integration) {
        setState(() {
          _currentPhase = ExplorationPhase.validation;
        });
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questionKeys.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentPhase = ExplorationPhase.manipulation;
        _integrationTimerStarted = false;
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
                const SizedBox(height: 8),
                Text(
                  '(0 = Minimum, 10 = Maximum)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.gold.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
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
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0\nMin',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '10\nMax',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
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

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle,
            size: 120,
            color: AppTheme.azure.withOpacity(0.6),
          ),
          const SizedBox(height: 48),
          Text(
            'Le Cercle Miroir',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Le cercle que vous allez voir représente votre image intérieure.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Ce n\'est pas une photo concrète, mais un symbole qui reflète votre représentation mentale.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Les gestes que vous ferez (glisser, pincer) donnent un mouvement physique à une idée intérieure.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _dismissIntroduction,
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(String questionKey) {
    switch (questionKey) {
      case 'distance':
        return _ThreePhaseExercise(
          questionKey: questionKey,
          phase: _currentPhase,
          integrationInstruction: _integrationInstructions[questionKey]!,
          integrationTimerStarted: _integrationTimerStarted,
          onStartIntegration: _startIntegrationPhase,
          onStartTimer: _startIntegrationTimer,
          onValidate: _nextQuestion,
          manipulationWidget: Column(
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
          ),
        );

      case 'brightness':
        return _ThreePhaseExercise(
          questionKey: questionKey,
          phase: _currentPhase,
          integrationInstruction: _integrationInstructions[questionKey]!,
          integrationTimerStarted: _integrationTimerStarted,
          onStartIntegration: _startIntegrationPhase,
          onStartTimer: _startIntegrationTimer,
          onValidate: _nextQuestion,
          manipulationWidget: SubmodalitySlider(
            question: HypnoticTexts.submodalityQuestions['brightness']!,
            value: _workingSubmodality.brightness,
            onChanged: (value) {
              _triggerHaptic();
              setState(() {
                _workingSubmodality = _workingSubmodality.copyWith(brightness: value);
              });
            },
            leftLabel: 'Sombre',
            rightLabel: 'Lumineux',
            visualFeedback: _BrightnessVisual(brightness: _workingSubmodality.brightness),
          ),
        );

      case 'size':
        return _ThreePhaseExercise(
          questionKey: questionKey,
          phase: _currentPhase,
          integrationInstruction: _integrationInstructions[questionKey]!,
          integrationTimerStarted: _integrationTimerStarted,
          onStartIntegration: _startIntegrationPhase,
          onStartTimer: _startIntegrationTimer,
          onValidate: _nextQuestion,
          manipulationWidget: Column(
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
          ),
        );

      case 'color':
        return _ThreePhaseExercise(
          questionKey: questionKey,
          phase: _currentPhase,
          integrationInstruction: _integrationInstructions[questionKey]!,
          integrationTimerStarted: _integrationTimerStarted,
          onStartIntegration: _startIntegrationPhase,
          onStartTimer: _startIntegrationTimer,
          onValidate: _nextQuestion,
          manipulationWidget: ColorPicker(
            question: HypnoticTexts.submodalityQuestions['color']!,
            selectedColorValue: _workingSubmodality.colorValue,
            onColorSelected: (colorValue) {
              setState(() {
                _workingSubmodality = _workingSubmodality.copyWith(colorValue: colorValue);
              });
            },
          ),
        );

      case 'clarity':
        return _ThreePhaseExercise(
          questionKey: questionKey,
          phase: _currentPhase,
          integrationInstruction: _integrationInstructions[questionKey]!,
          integrationTimerStarted: _integrationTimerStarted,
          onStartIntegration: _startIntegrationPhase,
          onStartTimer: _startIntegrationTimer,
          onValidate: _nextQuestion,
          manipulationWidget: SubmodalitySlider(
            question: HypnoticTexts.submodalityQuestions['clarity']!,
            value: _workingSubmodality.clarity,
            onChanged: (value) {
              _triggerHaptic();
              setState(() {
                _workingSubmodality = _workingSubmodality.copyWith(clarity: value);
              });
            },
            leftLabel: 'Flou',
            rightLabel: 'Net',
            visualFeedback: _ClarityVisual(clarity: _workingSubmodality.clarity),
          ),
        );

      case 'sound':
        return _ThreePhaseExercise(
          questionKey: questionKey,
          phase: _currentPhase,
          integrationInstruction: _integrationInstructions[questionKey]!,
          integrationTimerStarted: _integrationTimerStarted,
          onStartIntegration: _startIntegrationPhase,
          onStartTimer: _startIntegrationTimer,
          onValidate: _nextQuestion,
          manipulationWidget: _SoundSelector(
            currentLevel: _workingSubmodality.soundLevel,
            onChanged: (level) {
              setState(() {
                _workingSubmodality = _workingSubmodality.copyWith(soundLevel: level);
              });
            },
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _triggerHaptic() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 20);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntroduction) {
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
            child: _buildIntroduction(),
          ),
        ),
      );
    }

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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    key: ValueKey('${_currentQuestionIndex}_${_currentPhase.name}'),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildQuestionWidget(_questionKeys[_currentQuestionIndex]),
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

/// Widget qui encapsule la structure 3 phases (YO/YF)
class _ThreePhaseExercise extends StatelessWidget {
  final String questionKey;
  final ExplorationPhase phase;
  final String integrationInstruction;
  final bool integrationTimerStarted;
  final VoidCallback onStartIntegration;
  final VoidCallback onStartTimer;
  final VoidCallback onValidate;
  final Widget manipulationWidget;

  const _ThreePhaseExercise({
    required this.questionKey,
    required this.phase,
    required this.integrationInstruction,
    required this.integrationTimerStarted,
    required this.onStartIntegration,
    required this.onStartTimer,
    required this.onValidate,
    required this.manipulationWidget,
  });

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case ExplorationPhase.manipulation:
        // Phase 1: Manipulation (YO)
        return Column(
          children: [
            Expanded(child: manipulationWidget),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: onStartIntegration,
                child: const Text('Fermer les yeux et ressentir'),
              ),
            ),
          ],
        );

      case ExplorationPhase.integration:
        // Phase 2: Intégration (YF)
        if (!integrationTimerStarted) {
          // Show instruction and start timer automatically
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onStartTimer();
          });
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_off,
                  size: 80,
                  color: AppTheme.gold.withOpacity(0.6),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .fadeIn(duration: 2000.ms)
                    .then()
                    .fadeOut(duration: 2000.ms),
                const SizedBox(height: 48),
                Text(
                  integrationInstruction,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.gold,
                        height: 1.8,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 1500.ms, delay: 500.ms),
              ],
            ),
          ),
        );

      case ExplorationPhase.validation:
        // Phase 3: Validation (YO)
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: AppTheme.emerald,
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              'Ouvrez les yeux.\nNous passons à l\'attribut suivant.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: AppTheme.gold,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: 300.ms),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: onValidate,
              child: const Text('Suivant'),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms),
          ],
        );
    }
  }
}

// Visual feedback widgets
class _BrightnessVisual extends StatelessWidget {
  final double brightness;
  const _BrightnessVisual({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.azure.withOpacity(brightness),
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
    // Changed from rectangle to circle
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(110), // Circular shape
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: (1 - clarity) * 10,
            sigmaY: (1 - clarity) * 10,
          ),
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Circle instead of rounded rectangle
              color: AppTheme.azure.withOpacity(0.6), // Changed to azur
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

  Future<void> _triggerHaptic() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 20);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxOffset = screenWidth * 0.35;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        _triggerHaptic();
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
                width: 200 - (widget.distance * 100), // Proche = grand, Éloigné = petit
                height: 200 - (widget.distance * 100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.azure.withOpacity(0.2 + (1 - widget.distance) * 0.4), // Proche = plus opaque
                      AppTheme.primary.withOpacity(0.1 + (1 - widget.distance) * 0.3),
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

  Future<void> _triggerHaptic() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 20);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        _triggerHaptic();
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
            // Interactive circle (CHANGED TO AZUR)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 100 + (widget.size * 150), // Min 100, Max 250
                height: 100 + (widget.size * 150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.azure.withOpacity(0.7), // Changed from emerald to azur
                      AppTheme.azure.withOpacity(0.4),
                      AppTheme.azure.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.azure.withOpacity(0.4), // Changed from emerald to azur
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.open_in_full,
                    size: 40 + (widget.size * 30), // Icon proportionnel
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
