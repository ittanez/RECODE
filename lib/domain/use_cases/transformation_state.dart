import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/submodality.dart';
import '../../data/models/transformation.dart';
import '../../data/repositories/transformation_repository.dart';

class TransformationState {
  final String? theme;
  final Submodality currentSubmodality;
  final int intensityBefore;
  final int intensityAfter;
  final String? userNote;
  final bool isTransforming;

  const TransformationState({
    this.theme,
    required this.currentSubmodality,
    this.intensityBefore = 5,
    this.intensityAfter = 5,
    this.userNote,
    this.isTransforming = false,
  });

  TransformationState copyWith({
    String? theme,
    Submodality? currentSubmodality,
    int? intensityBefore,
    int? intensityAfter,
    String? userNote,
    bool? isTransforming,
  }) {
    return TransformationState(
      theme: theme ?? this.theme,
      currentSubmodality: currentSubmodality ?? this.currentSubmodality,
      intensityBefore: intensityBefore ?? this.intensityBefore,
      intensityAfter: intensityAfter ?? this.intensityAfter,
      userNote: userNote ?? this.userNote,
      isTransforming: isTransforming ?? this.isTransforming,
    );
  }
}

class TransformationNotifier extends StateNotifier<TransformationState> {
  final TransformationRepository _repository = TransformationRepository();

  TransformationNotifier()
      : super(TransformationState(
          currentSubmodality: Submodality.neutral(),
        ));

  void selectTheme(String theme) {
    state = state.copyWith(theme: theme);
  }

  void updateSubmodality(Submodality submodality) {
    state = state.copyWith(currentSubmodality: submodality);
  }

  void updateIntensityBefore(int intensity) {
    state = state.copyWith(intensityBefore: intensity);
  }

  void updateIntensityAfter(int intensity) {
    state = state.copyWith(intensityAfter: intensity);
  }

  void updateUserNote(String note) {
    state = state.copyWith(userNote: note);
  }

  void setTransforming(bool transforming) {
    state = state.copyWith(isTransforming: transforming);
  }

  Future<void> saveTransformation(Submodality transformedSubmodality) async {
    if (state.theme == null) return;

    final transformation = Transformation(
      date: DateTime.now().toIso8601String(),
      theme: state.theme!,
      intensityBefore: state.intensityBefore,
      intensityAfter: state.intensityAfter,
      userNote: state.userNote,
      submodalitiesBefore: state.currentSubmodality,
      submodalitiesAfter: transformedSubmodality,
    );

    await _repository.insertTransformation(transformation);
  }

  void reset() {
    state = TransformationState(
      currentSubmodality: Submodality.neutral(),
    );
  }
}

// Provider
final transformationProvider =
    StateNotifierProvider<TransformationNotifier, TransformationState>((ref) {
  return TransformationNotifier();
});

// Repository Provider
final transformationRepositoryProvider = Provider<TransformationRepository>((ref) {
  return TransformationRepository();
});
