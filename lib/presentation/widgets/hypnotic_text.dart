import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HypnoticText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration delay;
  final TextAlign textAlign;

  const HypnoticText({
    super.key,
    required this.text,
    this.style,
    this.delay = Duration.zero,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style ?? Theme.of(context).textTheme.headlineLarge,
    )
        .animate()
        .fadeIn(duration: 1500.ms, delay: delay, curve: Curves.easeInOut)
        .slideY(begin: 0.1, end: 0, duration: 1500.ms, delay: delay);
  }
}

class SequentialHypnoticTexts extends StatefulWidget {
  final List<String> texts;
  final Duration intervalBetweenTexts;
  final VoidCallback? onComplete;

  const SequentialHypnoticTexts({
    super.key,
    required this.texts,
    this.intervalBetweenTexts = const Duration(seconds: 3),
    this.onComplete,
  });

  @override
  State<SequentialHypnoticTexts> createState() =>
      _SequentialHypnoticTextsState();
}

class _SequentialHypnoticTextsState extends State<SequentialHypnoticTexts> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() async {
    for (int i = 0; i < widget.texts.length; i++) {
      await Future.delayed(widget.intervalBetweenTexts);
      if (mounted) {
        setState(() {
          _currentIndex = i;
        });
      }
    }
    if (widget.onComplete != null && mounted) {
      await Future.delayed(widget.intervalBetweenTexts);
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: HypnoticText(
        key: ValueKey<int>(_currentIndex),
        text: widget.texts[_currentIndex],
      ),
    );
  }
}
