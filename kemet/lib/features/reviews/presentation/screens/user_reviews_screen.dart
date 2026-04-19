import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';
import 'package:kemet/features/landmarks/domain/usecases/get_landmark_by_id.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/reviews/presentation/cubit/user_reviews_cubit.dart';
import 'package:kemet/features/reviews/presentation/widgets/user_review_card.dart';

class UserReviewsScreen extends StatefulWidget {
  const UserReviewsScreen({super.key, required this.userId});

  final String userId;

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  _LandmarkLookupCache? _landmarkLookup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserReviewsCubit>().loadReviews(widget.userId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _landmarkLookup ??= _LandmarkLookupCache(
      GetLandmarkByIdUseCase(context.read<LandmarksRepository>()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161311),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MY REVIEWS',
          style: TextStyle(
            color: Color(0xFFC59D5F),
            letterSpacing: 2.0,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC59D5F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<UserReviewsCubit, UserReviewsState>(
          builder: (context, state) {
            if (state is UserReviewsLoading || state is UserReviewsInitial) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFEBC07E)),
              );
            }

            if (state is UserReviewsError) {
              return _ErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<UserReviewsCubit>().loadReviews(widget.userId),
              );
            }

            if (state is UserReviewsLoaded) {
              if (state.reviews.isEmpty) {
                return const _EmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  final review = state.reviews[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ReviewItem(
                      review: review,
                      lookup: _landmarkLookup,
                      onTap: () => _openLandmark(review),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _openLandmark(Review review) async {
    final lookup = _landmarkLookup;
    if (lookup == null) {
      return;
    }

    final landmark = await lookup.getLandmark(review.landmarkId);
    if (!mounted) {
      return;
    }

    if (landmark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Landmark details are unavailable.')),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      Routes.landmarkDetails,
      arguments: landmark,
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.review,
    required this.lookup,
    required this.onTap,
  });

  final Review review;
  final _LandmarkLookupCache? lookup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lookupCache = lookup;
    if (lookupCache == null) {
      return UserReviewCard(
        review: review,
        landmarkName: review.landmarkName.isNotEmpty
            ? review.landmarkName
            : review.landmarkId,
        onTap: onTap,
        onLandmarkTap: onTap,
      );
    }

    return FutureBuilder<Landmark?>(
      future: lookupCache.getLandmark(review.landmarkId),
      builder: (context, snapshot) {
        final landmark = snapshot.data;
        final displayName = _displayLandmarkName(review, landmark);
        return UserReviewCard(
          review: review,
          landmarkName: displayName,
          onTap: onTap,
          onLandmarkTap: onTap,
        );
      },
    );
  }

  String _displayLandmarkName(Review review, Landmark? landmark) {
    final stored = review.landmarkName.trim();
    if (stored.isNotEmpty) {
      return stored;
    }
    final resolved = landmark?.name.trim() ?? '';
    if (resolved.isNotEmpty) {
      return resolved;
    }
    return review.landmarkId;
  }
}

class _LandmarkLookupCache {
  _LandmarkLookupCache(this._getLandmarkByIdUseCase);

  final GetLandmarkByIdUseCase _getLandmarkByIdUseCase;
  final Map<String, Future<Landmark?>> _landmarkFutures = {};

  Future<Landmark?> getLandmark(String id) {
    return _landmarkFutures.putIfAbsent(
      id,
      () async {
        final result = await _getLandmarkByIdUseCase(id);
        return result.fold(
          (_) => null,
          (landmark) => landmark,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B19),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4E4539).withOpacity(0.3)),
        ),
        child: const Text(
          'No reviews yet. Share your first experience!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD2C4B5),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}


class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B19),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4E4539).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD2C4B5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEBC07E),
              ),
              child: const Text(
                'RETRY',
                style: TextStyle(letterSpacing: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
