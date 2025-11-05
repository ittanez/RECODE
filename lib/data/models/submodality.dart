class Submodality {
  final double distance; // 0.0 (proche) à 1.0 (éloigné)
  final double brightness; // 0.0 (sombre) à 1.0 (lumineux)
  final double size; // 0.0 (petit) à 1.0 (grand)
  final int colorValue; // Color.value
  final double clarity; // 0.0 (flou) à 1.0 (net)
  final String soundLevel; // 'silent', 'soft', 'loud'

  const Submodality({
    required this.distance,
    required this.brightness,
    required this.size,
    required this.colorValue,
    required this.clarity,
    required this.soundLevel,
  });

  // Submodalité par défaut (neutre)
  factory Submodality.neutral() {
    return const Submodality(
      distance: 0.5,
      brightness: 0.5,
      size: 0.5,
      colorValue: 0xFF808080, // Gris
      clarity: 0.5,
      soundLevel: 'silent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'distance': distance,
      'brightness': brightness,
      'size': size,
      'colorValue': colorValue,
      'clarity': clarity,
      'soundLevel': soundLevel,
    };
  }

  factory Submodality.fromMap(Map<String, dynamic> map) {
    return Submodality(
      distance: map['distance'] as double,
      brightness: map['brightness'] as double,
      size: map['size'] as double,
      colorValue: map['colorValue'] as int,
      clarity: map['clarity'] as double,
      soundLevel: map['soundLevel'] as String,
    );
  }

  Submodality copyWith({
    double? distance,
    double? brightness,
    double? size,
    int? colorValue,
    double? clarity,
    String? soundLevel,
  }) {
    return Submodality(
      distance: distance ?? this.distance,
      brightness: brightness ?? this.brightness,
      size: size ?? this.size,
      colorValue: colorValue ?? this.colorValue,
      clarity: clarity ?? this.clarity,
      soundLevel: soundLevel ?? this.soundLevel,
    );
  }
}
