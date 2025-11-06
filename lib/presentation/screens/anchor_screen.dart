import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
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

enum AnchorType { fingerPress, wristTouch, fingerCross }

class _AnchorScreenState extends ConsumerState<AnchorScreen> {
  AnchorType? _selectedAnchor;
  int _anchorCount = 0;
  final int _maxAnchors = 3;

  Future<void> _performAnchor() async {
    if (_anchorCount < _maxAnchors) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      } else {
        HapticFeedback.mediumImpact();
      }

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
          child: _selectedAnchor == null ? _buildAnchorSelection() : _buildAnchorPractice(),
        ),
      ),
    );
  }

  Widget _buildAnchorSelection() {
    return Column(
      children: [
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Choisissez votre ancrage physique',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 1000.ms),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Un geste simple que vous pourrez reproduire n\'importe où',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 1000.ms, delay: 300.ms),
        ),
        const Spacer(),
        _AnchorOption(
          type: AnchorType.fingerPress,
          label: 'Presser deux doigts',
          description: 'Pressez votre pouce contre votre index',
          icon: '👌',
          onTap: () => setState(() => _selectedAnchor = AnchorType.fingerPress),
        ),
        const SizedBox(height: 24),
        _AnchorOption(
          type: AnchorType.wristTouch,
          label: 'Toucher le poignet',
          description: 'Touchez votre poignet avec deux doigts',
          icon: '✌️',
          onTap: () => setState(() => _selectedAnchor = AnchorType.wristTouch),
        ),
        const SizedBox(height: 24),
        _AnchorOption(
          type: AnchorType.fingerCross,
          label: 'Croiser les doigts',
          description: 'Croisez l\'index et le majeur',
          icon: '🤞',
          onTap: () => setState(() => _selectedAnchor = AnchorType.fingerCross),
        ),
        const Spacer(),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildAnchorPractice() {
    String instruction = '';
    switch (_selectedAnchor!) {
      case AnchorType.fingerPress:
        instruction = 'Pressez fermement votre pouce\ncontre votre index';
        break;
      case AnchorType.wristTouch:
        instruction = 'Touchez votre poignet\navec deux doigts';
        break;
      case AnchorType.fingerCross:
        instruction = 'Croisez votre index\net votre majeur';
    }

    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Créez votre ancrage',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            instruction,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          '$_anchorCount / $_maxAnchors',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.gold,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: _performAnchor,
          child: Container(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _anchorCount >= _maxAnchors ? Icons.check : Icons.touch_app,
                    size: 60,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faites le geste\npuis touchez ici',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 1500.ms)
            .then()
            .fadeOut(duration: 1500.ms),
        const Spacer(),
        if (_anchorCount >= _maxAnchors)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Text(
              'Votre ancrage est créé ✨\nVous pourrez le reproduire n\'importe où',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.gold,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 1000.ms)
                .slideY(begin: 0.2, end: 0),
          ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _AnchorOption extends StatelessWidget {
  final AnchorType type;
  final String label;
  final String description;
  final String icon;
  final VoidCallback onTap;

  const _AnchorOption({
    required this.type,
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withOpacity(0.3),
              AppTheme.secondary.withOpacity(0.2),
            ],
          ),
          border: Border.all(
            color: AppTheme.gold.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0),
    );
  }
}
