import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SubmodalitySlider extends StatelessWidget {
  final String question;
  final double value;
  final ValueChanged<double> onChanged;
  final String? leftLabel;
  final String? rightLabel;
  final Widget? visualFeedback;

  const SubmodalitySlider({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    this.leftLabel,
    this.rightLabel,
    this.visualFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Text(
            question,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        if (visualFeedback != null) ...[
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: visualFeedback,
          ),
          const SizedBox(height: 32),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Slider(
                value: value,
                onChanged: onChanged,
                min: 0.0,
                max: 1.0,
                divisions: 100,
              ),
              if (leftLabel != null && rightLabel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leftLabel!,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        rightLabel!,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ColorPicker extends StatelessWidget {
  final String question;
  final int selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const ColorPicker({
    super.key,
    required this.question,
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  static const List<int> colors = [
    0xFF808080, // Gris
    0xFFFF0000, // Rouge
    0xFFFF8800, // Orange
    0xFFFFFF00, // Jaune
    0xFF00FF00, // Vert
    0xFF0000FF, // Bleu
    0xFF4B0082, // Indigo
    0xFF9400D3, // Violet
    0xFFFFD700, // Or
    0xFF50C878, // Émeraude
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Text(
            question,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: colors.map((colorValue) {
            final isSelected = colorValue == selectedColorValue;
            return GestureDetector(
              onTap: () => onColorSelected(colorValue),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(colorValue),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.gold : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
