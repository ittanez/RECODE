import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'exploration_screen.dart';

/// Écran de création de l'image mentale initiale (30 secondes)
/// L'utilisateur ferme les yeux et se représente ce qu'il veut transformer
class MentalImageCreationScreen extends StatefulWidget {
  const MentalImageCreationScreen({super.key});

  @override
  State<MentalImageCreationScreen> createState() => _MentalImageCreationScreenState();
}

class _MentalImageCreationScreenState extends State<MentalImageCreationScreen> {
  bool _timerStarted = false;
  int _secondsRemaining = 30;

  void _startTimer() {
    setState(() {
      _timerStarted = true;
    });

    // Décompte de 30 secondes
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        // Attendre 2 secondes puis naviguer
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _navigateToExploration();
        }
        return false;
      }
      return true;
    });
  }

  void _navigateToExploration() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ExplorationScreen(),
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
              AppTheme.secondary.withOpacity(0.3),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: _timerStarted ? _buildTimerView() : _buildInstructionView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.visibility_off_outlined,
          size: 100,
          color: AppTheme.gold.withOpacity(0.8),
        )
            .animate()
            .fadeIn(duration: 1000.ms)
            .scale(delay: 300.ms, duration: 800.ms),
        const SizedBox(height: 48),
        Text(
          'Création de votre image mentale',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
              ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 400.ms),
        const SizedBox(height: 32),
        Text(
          'Dans quelques instants, vous allez fermer les yeux pendant 30 secondes.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.8,
              ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 600.ms),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.gold.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Text(
            'Représentez-vous PAR UNE IMAGE ce que vous souhaitez transformer.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gold,
                  height: 1.8,
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 800.ms)
            .scale(delay: 800.ms, duration: 600.ms),
        const SizedBox(height: 48),
        Text(
          'Prenez le temps de visualiser cette image mentalement.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 1000.ms),
        const SizedBox(height: 64),
        ElevatedButton(
          onPressed: _startTimer,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            backgroundColor: AppTheme.gold.withOpacity(0.2),
          ),
          child: const Text(
            'Je suis prêt(e)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 1200.ms)
            .scale(delay: 1200.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildTimerView() {
    final isFinished = _secondsRemaining <= 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isFinished) ...[
          Icon(
            Icons.visibility_off,
            size: 120,
            color: AppTheme.gold.withOpacity(0.6),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 2000.ms)
              .then()
              .fadeOut(duration: 2000.ms),
          const SizedBox(height: 64),
          Text(
            'Fermez les yeux',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 1500.ms),
          const SizedBox(height: 48),
          Text(
            'Représentez-vous par une image\nce que vous voulez transformer',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textPrimary,
                  height: 1.8,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 1500.ms, delay: 500.ms),
          const SizedBox(height: 64),
          // Timer countdown
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.gold.withOpacity(0.5),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '$_secondsRemaining',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gold,
                    ),
              ),
            ),
          )
              .animate()
              .scale(duration: 1000.ms, curve: Curves.easeOut),
          const SizedBox(height: 24),
          Text(
            'secondes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ] else ...[
          Icon(
            Icons.check_circle,
            size: 100,
            color: AppTheme.emerald,
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 48),
          Text(
            'Parfait !',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.emerald,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 300.ms),
          const SizedBox(height: 24),
          Text(
            'Nous allons maintenant explorer VOTRE image...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 600.ms),
        ],
      ],
    );
  }
}
