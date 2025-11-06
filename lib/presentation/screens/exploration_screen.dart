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

/// Phase d'exploration (Protocole YF/YO - CORRECT)
enum ExplorationPhase {
  observation,   // Phase 1: Observer VOTRE image (Yeux Fermés - 10-15s)
  adjustment,    // Phase 2: Ajuster le cercle (Yeux Ouverts - manipulation)
  validation,    // Phase 3: Confirmer (Yeux Ouverts - "Est-ce correct?")
}

class ExplorationScreen extends ConsumerStatefulWidget {
  const ExplorationScreen({super.key});

  @override
  ConsumerState<ExplorationScreen> createState() => _ExplorationScreenState();
}

class _ExplorationScreenState extends ConsumerState<ExplorationScreen> {
  int _currentQuestionIndex = 0;
  ExplorationPhase _currentPhase = ExplorationPhase.observation;
  late Submodality _workingSubmodality;
  bool _observationTimerStarted = false;

  final List<String> _questionKeys = [
    'distance',
    'brightness',
    'size',
    'color',
    'clarity',
    'sound',
  ];

  // Instructions pour la phase d'observation (YF)
  final Map<String, String> _observationInstructions = {
    'distance': 'Fermez les yeux.\nObservez VOTRE image.\n\nCette image est-elle proche ou éloignée de vous ?',
    'brightness': 'Fermez les yeux.\nObservez VOTRE image.\n\nEst-elle lumineuse ou sombre ?',
    'size': 'Fermez les yeux.\nObservez VOTRE image.\n\nEst-elle grande ou petite ?',
    'color': 'Fermez les yeux.\nObservez VOTRE image.\n\nQuelle est sa couleur dominante ?',
    'clarity': 'Fermez les yeux.\nObservez VOTRE image.\n\nEst-elle nette ou floue ?',
    'sound': 'Fermez les yeux.\nObservez VOTRE image.\n\nY a-t-il un son associé à cette image ?',
  };

  @override
  void initState() {
    super.initState();
    _workingSubmodality = Submodality.neutral();
  }

  void _startObservationTimer() {
    setState(() {
      _observationTimerStarted = true;
    });

    // Timer de 12 secondes pour la phase d'observation
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _currentPhase == ExplorationPhase.observation) {
        setState(() {
          _currentPhase = ExplorationPhase.adjustment;
        });
      }
    });
  }

  void _startValidation() {
    setState(() {
      _currentPhase = ExplorationPhase.validation;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questionKeys.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentPhase = ExplorationPhase.observation;
        _observationTimerStarted = false;
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

  Widget _buildQuestionWidget(String questionKey) {
    switch (questionKey) {
      case 'distance':
        return _ThreePhaseExercise(
          questionKey: questionKey,
          phase: _currentPhase,
          observationInstruction: _observationInstructions[questionKey]!,
          observationTimerStarted: _observationTimerStarted,
          onStartObservationTimer: _startObservationTimer,
          onStartValidation: _startValidation,
          onValidate: _nextQuestion,
          adjustmentWidget: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Text(
                  'Ajustez le cercle selon ce que vous avez observé',
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
          observationInstruction: _observationInstructions[questionKey]!,
          observationTimerStarted: _observationTimerStarted,
          onStartObservationTimer: _startObservationTimer,
          onStartValidation: _startValidation,
          onValidate: _nextQuestion,
          adjustmentWidget: SubmodalitySlider(
            question: 'Ajustez la luminosité de VOTRE image',
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
          observationInstruction: _observationInstructions[questionKey]!,
          observationTimerStarted: _observationTimerStarted,
          onStartObservationTimer: _startObservationTimer,
          onStartValidation: _startValidation,
          onValidate: _nextQuestion,
          adjustmentWidget: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Text(
                  'Ajustez le cercle selon ce que vous avez observé',
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
          observationInstruction: _observationInstructions[questionKey]!,
          observationTimerStarted: _observationTimerStarted,
          onStartObservationTimer: _startObservationTimer,
          onStartValidation: _startValidation,
          onValidate: _nextQuestion,
          adjustmentWidget: ColorPicker(
            question: 'Choisissez la couleur dominante de VOTRE image',
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
          observationInstruction: _observationInstructions[questionKey]!,
          observationTimerStarted: _observationTimerStarted,
          onStartObservationTimer: _startObservationTimer,
          onStartValidation: _startValidation,
          onValidate: _nextQuestion,
          adjustmentWidget: SubmodalitySlider(
            question: 'Ajustez la netteté de VOTRE image',
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
          observationInstruction: _observationInstructions[questionKey]!,
          observationTimerStarted: _observationTimerStarted,
          onStartObservationTimer: _startObservationTimer,
          onStartValidation: _startValidation,
          onValidate: _nextQuestion,
          adjustmentWidget: _SoundSelector(
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

/// Widget qui encapsule la structure 3 phases (YF → YO → YO)
class _ThreePhaseExercise extends StatelessWidget {
  final String questionKey;
  final ExplorationPhase phase;
  final String observationInstruction;
  final bool observationTimerStarted;
  final VoidCallback onStartObservationTimer;
  final VoidCallback onStartValidation;
  final VoidCallback onValidate;
  final Widget adjustmentWidget;

  const _ThreePhaseExercise({
    required this.questionKey,
    required this.phase,
    required this.observationInstruction,
    required this.observationTimerStarted,
    required this.onStartObservationTimer,
    required this.onStartValidation,
    required this.onValidate,
    required this.adjustmentWidget,
  });

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case ExplorationPhase.observation:
        // Phase 1: Observation (YF - Yeux Fermés)
        if (!observationTimerStarted) {
          // Start timer automatically when entering observation phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onStartObservationTimer();
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
                  size: 100,
                  color: AppTheme.gold.withOpacity(0.6),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .fadeIn(duration: 2000.ms)
                    .then()
                    .fadeOut(duration: 2000.ms),
                const SizedBox(height: 64),
                Text(
                  observationInstruction,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
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

      case ExplorationPhase.adjustment:
        // Phase 2: Ajustement (YO - Yeux Ouverts)
        return Column(
          children: [
            // Instruction "Ouvrez les yeux"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.emerald.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility,
                    color: AppTheme.emerald,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ouvrez les yeux',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.emerald,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Expanded(child: adjustmentWidget),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: onStartValidation,
                child: const Text('J\'ai ajusté'),
              ),
            ),
          ],
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
              'Est-ce correct ?',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: 300.ms),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: onValidate,
              child: const Text('Oui, continuer'),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms),
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
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(110),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: (1 - clarity) * 10,
            sigmaY: (1 - clarity) * 10,
          ),
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.azure.withOpacity(0.6),
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
            'Sélectionnez le niveau sonore de VOTRE image',
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
          final normalizedDistance = ((_dragOffset + maxOffset) / (maxOffset * 2)).clamp(0.0, 1.0);
          widget.onDistanceChanged(normalizedDistance);
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
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
            Center(
              child: Container(
                width: 200 - (widget.distance * 100),
                height: 200 - (widget.distance * 100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.azure.withOpacity(0.2 + (1 - widget.distance) * 0.4),
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
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 100 + (widget.size * 150),
                height: 100 + (widget.size * 150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.azure.withOpacity(0.7),
                      AppTheme.azure.withOpacity(0.4),
                      AppTheme.azure.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.azure.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.open_in_full,
                    size: 40 + (widget.size * 30),
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
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
