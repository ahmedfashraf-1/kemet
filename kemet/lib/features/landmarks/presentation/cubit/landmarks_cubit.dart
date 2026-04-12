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
    String? query,
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
      query: query,
    );

    failureOrLandmarks.fold(
      (failure) => emit(LandmarksError(message: _mapFailureToMessage(failure))),
      (landmarks) {
        final filtered = _applyTitleSearch(landmarks, query);
        final hasQuery = query != null && query.trim().isNotEmpty;
        final paginated = hasQuery
            ? _paginateFiltered(filtered, page: page, limit: pageSize)
            : filtered;
        final isLastPage = hasQuery
            ? (page * pageSize) >= filtered.length
            : landmarks.length < pageSize;

        emit(
          LandmarksLoaded(
            landmarks: paginated,
            currentPage: page,
            city: city,
            kind: kind,
            query: query,
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
          query: currentState.query,
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
          query: currentState.query,
          isPagination: true,
        );
      }
    }
  }

  void applyFilter({String? city, String? kind, String? query}) {
    getLandmarks(page: 1, city: city, kind: kind, query: query);
  }

  List<Landmark> _applyTitleSearch(List<Landmark> items, String? query) {
    final trimmed = query?.trim() ?? '';
    if (trimmed.isEmpty) return items;

    final normalizedQuery = _normalize(trimmed);
    if (normalizedQuery.isEmpty) return items;

    return items.where((landmark) {
      final title = _normalize(landmark.name);
      return _matchesTitle(title, normalizedQuery);
    }).toList();
  }

  List<Landmark> _paginateFiltered(
    List<Landmark> items, {
    required int page,
    required int limit,
  }) {
    if (items.isEmpty) return const [];
    final startIndex = (page - 1) * limit;
    if (startIndex >= items.length) return const [];
    final endIndex = (startIndex + limit).clamp(0, items.length);
    return items.sublist(startIndex, endIndex);
  }

  bool _matchesTitle(String title, String query) {
    if (title.isEmpty) return false;
    if (title.contains(query)) return true;

    final titleTokens = title.split(' ');
    final queryTokens = query.split(' ');

    for (final q in queryTokens) {
      if (q.isEmpty) continue;
      if (titleTokens.any((t) => t.contains(q))) return true;
    }

    return _isFuzzyMatch(title, query);
  }

  bool _isFuzzyMatch(String title, String query) {
    final maxDistance = query.length <= 4 ? 1 : 2;
    if (_levenshteinDistance(title, query) <= maxDistance) return true;

    for (final token in title.split(' ')) {
      if (token.isEmpty) continue;
      if (_levenshteinDistance(token, query) <= maxDistance) return true;
    }
    return false;
  }

  String _normalize(String input) {
    final lower = input.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final prev = List<int>.generate(b.length + 1, (i) => i);
    final curr = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      curr[0] = i;
      final aChar = a.codeUnitAt(i - 1);
      for (var j = 1; j <= b.length; j++) {
        final cost = aChar == b.codeUnitAt(j - 1) ? 0 : 1;
        final insertion = curr[j - 1] + 1;
        final deletion = prev[j] + 1;
        final substitution = prev[j - 1] + cost;
        curr[j] = _min3(insertion, deletion, substitution);
      }
      for (var j = 0; j <= b.length; j++) {
        prev[j] = curr[j];
      }
    }

    return prev[b.length];
  }

  int _min3(int a, int b, int c) {
    final ab = a < b ? a : b;
    return ab < c ? ab : c;
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
