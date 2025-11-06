import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/submodality.dart';
import '../../domain/use_cases/transformation_state.dart';
import 'feedback_screen.dart';

/// SWISH PATTERN (Technique PNL)
/// Image problème (grand/lumineux) → Image ressource (petit/sombre)
/// Répété 5 fois pour ancrer la transformation
class TransformationScreen extends ConsumerStatefulWidget {
  const TransformationScreen({super.key});

  @override
  ConsumerState<TransformationScreen> createState() => _TransformationScreenState();
}

class _TransformationScreenState extends ConsumerState<TransformationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _swishRepetition = 0; // 0 à 4 (5 répétitions)
  bool _showingProblemImage = true; // true = problème, false = ressource

  late Submodality _problemSubmodality; // Image problème (actuelle)
  late Submodality _resourceSubmodality; // Image ressource (transformée)

  @override
  void initState() {
    super.initState();

    // Récupérer l'image problème (ce que l'utilisateur a décrit)
    _problemSubmodality = ref.read(transformationProvider).currentSubmodality;

    // Créer l'image ressource (transformée selon principes PNL)
    _resourceSubmodality = _createResourceSubmodality();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // 1 seconde par SWISH
    );

    // Démarrer la séquence SWISH
    _startSwishSequence();
  }

  Submodality _createResourceSubmodality() {
    // Transformation selon principes PNL :
    // - Distance : Plus loin = moins intense
    // - Taille : Plus petit = moins accablant
    // - Luminosité : Plus lumineux = plus positif
    // - Couleur : Émeraude (couleur ressource)
    // - Netteté : Légèrement plus nette pour clarté
    return _problemSubmodality.copyWith(
      distance: 0.7, // Plus éloigné
      size: 0.3, // Plus petit
      brightness: 0.9, // Plus lumineux
      colorValue: AppTheme.emerald.value, // Couleur ressource
      clarity: 0.7, // Plus net
      soundLevel: 'soft', // Son doux
    );
  }

  void _startSwishSequence() async {
    // Attendre 2 secondes pour afficher l'image problème
    await Future.delayed(const Duration(seconds: 2));

    // Répéter le SWISH 5 fois
    for (int i = 0; i < 5; i++) {
      if (!mounted) return;

      setState(() {
        _swishRepetition = i;
      });

      // SWISH : problème → ressource (1 seconde)
      _controller.reset();
      await _controller.forward();

      // Pause courte (0.5 seconde)
      await Future.delayed(const Duration(milliseconds: 500));

      // Réinitialiser pour la prochaine répétition
      if (i < 4) {
        setState(() {
          _showingProblemImage = true;
        });
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Attendre 2 secondes puis naviguer vers feedback
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _navigateToFeedback();
    }
  }

  void _navigateToFeedback() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FeedbackScreen(transformedSubmodality: _resourceSubmodality),
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
              AppTheme.secondary.withOpacity(0.3),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animation SWISH
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return _buildSwishAnimation();
                  },
                ),
              ),

              // Compteur de répétitions
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Répétition ${_swishRepetition + 1} / 5',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gold,
                          ),
                    ),
                  ),
                ),
              ),

              // Instructions
              Positioned(
                bottom: 80,
                left: 32,
                right: 32,
                child: Text(
                  _controller.isAnimating
                      ? 'SWISH ! Transformation en cours...'
                      : 'Observez la transformation...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.gold,
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

  Widget _buildSwishAnimation() {
    final progress = _controller.value;

    // Image problème : commence GRAND/LUMINEUX, devient PETIT/SOMBRE
    final problemSize = 250.0 - (progress * 200.0); // 250 → 50
    final problemBrightness = _problemSubmodality.brightness * (1.0 - progress * 0.8); // Devient sombre
    final problemScale = 1.0 - (progress * 0.8); // 1.0 → 0.2

    // Image ressource : commence PETIT/SOMBRE, devient GRAND/LUMINEUX
    final resourceSize = 50.0 + (progress * 200.0); // 50 → 250
    final resourceBrightness = _resourceSubmodality.brightness * progress; // Devient lumineux
    final resourceScale = 0.2 + (progress * 0.8); // 0.2 → 1.0

    return Stack(
      alignment: Alignment.center,
      children: [
        // Image PROBLÈME (disparaît)
        Positioned(
          child: Transform.scale(
            scale: problemScale,
            child: Opacity(
              opacity: 1.0 - progress,
              child: _buildCircle(
                submodality: _problemSubmodality,
                size: problemSize,
                brightness: problemBrightness,
              ),
            ),
          ),
        ),

        // Image RESSOURCE (apparaît)
        Positioned(
          child: Transform.scale(
            scale: resourceScale,
            child: Opacity(
              opacity: progress,
              child: _buildCircle(
                submodality: _resourceSubmodality,
                size: resourceSize,
                brightness: resourceBrightness,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircle({
    required Submodality submodality,
    required double size,
    required double brightness,
  }) {
    final blur = (1 - submodality.clarity) * 15;

    return ClipRRect(
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
                Color(submodality.colorValue).withOpacity(brightness),
                Color(submodality.colorValue).withOpacity(brightness * 0.5),
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
    );
  }
}
