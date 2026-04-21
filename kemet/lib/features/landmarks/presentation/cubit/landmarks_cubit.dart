import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:equatable/equatable.dart';
import 'package:kemet/core/strings/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/usecases/get_all_landmarks.dart';

part 'landmarks_state.dart';

class LandmarksCubit extends Cubit<LandmarksState> {
  final GetAllLandmarksUsecase getAllLandmarksUsecase;
  final int pageSize = 7;

  LandmarksCubit({required this.getAllLandmarksUsecase})
    : super(LandmarksInitial());

  Future<void> getLandmarks({
    int page = 1,
    String? city,
    String? kind,
    String? languageCode,
    bool isPagination = false,
  }) async {
    if (!isPagination) {
      emit(LandmarksLoading());
    }

    final failureOrLandmarks = await getAllLandmarksUsecase(
      page: page,
      limit: pageSize,
      city: city,
      kind: kind,
      languageCode: languageCode,
    );

    failureOrLandmarks.fold(
      (failure) => emit(LandmarksError(message: _mapFailureToMessage(failure))),
      (landmarks) {
        bool isLastPage = landmarks.length < pageSize;

        emit(
          LandmarksLoaded(
            landmarks: landmarks,
            currentPage: page,
            city: city,
            kind: kind,
            languageCode: languageCode ?? 'en',
            isLastPage: isLastPage,
          ),
        );
      },
    );
  }

  void nextPage() {
    if (state is LandmarksLoaded) {
      final currentState = state as LandmarksLoaded;
      if (!currentState.isLastPage) {
        getLandmarks(
          page: currentState.currentPage + 1,
          city: currentState.city,
          kind: currentState.kind,
          languageCode: currentState.languageCode,
          isPagination: true,
        );
      }
    }
  }

  void previousPage() {
    if (state is LandmarksLoaded) {
      final currentState = state as LandmarksLoaded;
      if (currentState.currentPage > 1) {
        getLandmarks(
          page: currentState.currentPage - 1,
          city: currentState.city,
          kind: currentState.kind,
          languageCode: currentState.languageCode,
          isPagination: true,
        );
      }
    }
  }

  void applyFilter({String? city, String? kind, String? languageCode}) {
    getLandmarks(page: 1, city: city, kind: kind, languageCode: languageCode);
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => serverFailureMessage,
      OfflineFailure() => offlineFailureMessage,
      EmptyCacheFailure() => emptyCacheFailureMessage,
      _ => unknownFailureMessage,
    };
  }
}
