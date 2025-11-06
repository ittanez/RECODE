import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/texts.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/use_cases/transformation_state.dart';
import '../widgets/animated_theme_icons.dart';
import 'mental_image_creation_screen.dart';

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              AppTheme.primary.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                'Que souhaitez-vous transformer ?',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 1000.ms)
                  .slideY(begin: -0.2, end: 0),

              const SizedBox(height: 48),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: HypnoticTexts.themes.entries.map((entry) {
                    return _ThemeCard(
                      themeKey: entry.key,
                      title: entry.value['title']!,
                      description: entry.value['description']!,
                      onTap: () {
                        ref.read(transformationProvider.notifier).selectTheme(entry.key);
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const MentalImageCreationScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 600),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatefulWidget {
  final String themeKey;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.themeKey,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> {
  bool _isHovered = false;

  Widget _getAnimatedIcon() {
    switch (widget.themeKey) {
      case 'fear':
        return DissolvingCloudIcon(size: 56, isHovered: _isHovered);
      case 'belief':
        return OpeningLockIcon(size: 56, isHovered: _isHovered);
      case 'memory':
        return HypnoticSpiralIcon(size: 56, isHovered: _isHovered);
      case 'resource':
        return SproutingSeedIcon(size: 56, isHovered: _isHovered);
      default:
        return const Icon(Icons.lightbulb, size: 56);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) {
          setState(() => _isHovered = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withOpacity(_isHovered ? 0.4 : 0.2),
                AppTheme.secondary.withOpacity(_isHovered ? 0.3 : 0.1),
              ],
            ),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.gold.withOpacity(0.5)
                  : AppTheme.primary.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppTheme.gold.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: _getAnimatedIcon(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0),
    );
  }
}
