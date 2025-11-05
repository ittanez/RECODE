import 'submodality.dart';

class Transformation {
  final int? id;
  final String date;
  final String theme;
  final int intensityBefore;
  final int intensityAfter;
  final String? userNote;
  final Submodality submodalitiesBefore;
  final Submodality submodalitiesAfter;

  const Transformation({
    this.id,
    required this.date,
    required this.theme,
    required this.intensityBefore,
    required this.intensityAfter,
    this.userNote,
    required this.submodalitiesBefore,
    required this.submodalitiesAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'theme': theme,
      'intensityBefore': intensityBefore,
      'intensityAfter': intensityAfter,
      'userNote': userNote,
      'submodalitiesBeforeDistance': submodalitiesBefore.distance,
      'submodalitiesBeforeBrightness': submodalitiesBefore.brightness,
      'submodalitiesBeforeSize': submodalitiesBefore.size,
      'submodalitiesBeforeColorValue': submodalitiesBefore.colorValue,
      'submodalitiesBeforeClarity': submodalitiesBefore.clarity,
      'submodalitiesBeforeSoundLevel': submodalitiesBefore.soundLevel,
      'submodalitiesAfterDistance': submodalitiesAfter.distance,
      'submodalitiesAfterBrightness': submodalitiesAfter.brightness,
      'submodalitiesAfterSize': submodalitiesAfter.size,
      'submodalitiesAfterColorValue': submodalitiesAfter.colorValue,
      'submodalitiesAfterClarity': submodalitiesAfter.clarity,
      'submodalitiesAfterSoundLevel': submodalitiesAfter.soundLevel,
    };
  }

  factory Transformation.fromMap(Map<String, dynamic> map) {
    return Transformation(
      id: map['id'] as int?,
      date: map['date'] as String,
      theme: map['theme'] as String,
      intensityBefore: map['intensityBefore'] as int,
      intensityAfter: map['intensityAfter'] as int,
      userNote: map['userNote'] as String?,
      submodalitiesBefore: Submodality(
        distance: map['submodalitiesBeforeDistance'] as double,
        brightness: map['submodalitiesBeforeBrightness'] as double,
        size: map['submodalitiesBeforeSize'] as double,
        colorValue: map['submodalitiesBeforeColorValue'] as int,
        clarity: map['submodalitiesBeforeClarity'] as double,
        soundLevel: map['submodalitiesBeforeSoundLevel'] as String,
      ),
      submodalitiesAfter: Submodality(
        distance: map['submodalitiesAfterDistance'] as double,
        brightness: map['submodalitiesAfterBrightness'] as double,
        size: map['submodalitiesAfterSize'] as double,
        colorValue: map['submodalitiesAfterColorValue'] as int,
        clarity: map['submodalitiesAfterClarity'] as double,
        soundLevel: map['submodalitiesAfterSoundLevel'] as String,
      ),
    );
  }

  Transformation copyWith({
    int? id,
    String? date,
    String? theme,
    int? intensityBefore,
    int? intensityAfter,
    String? userNote,
    Submodality? submodalitiesBefore,
    Submodality? submodalitiesAfter,
  }) {
    return Transformation(
      id: id ?? this.id,
      date: date ?? this.date,
      theme: theme ?? this.theme,
      intensityBefore: intensityBefore ?? this.intensityBefore,
      intensityAfter: intensityAfter ?? this.intensityAfter,
      userNote: userNote ?? this.userNote,
      submodalitiesBefore: submodalitiesBefore ?? this.submodalitiesBefore,
      submodalitiesAfter: submodalitiesAfter ?? this.submodalitiesAfter,
    );
  }
}
