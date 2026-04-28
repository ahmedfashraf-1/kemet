import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/widgets/join_kemet_dialog.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/reviews/presentation/cubit/reviews_cubit.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, required this.landmark});

  final Landmark landmark;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  List<Review> _latestReviews = const [];
  late final Stream<List<Review>> _reviewsStream;

  @override
  void initState() {
    super.initState();
    _reviewsStream =
        context.read<ReviewsCubit>().watchReviewsForLandmark(widget.landmark.id);
    debugPrint('ReviewsScreen landmarkId: ${widget.landmark.id}');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;
    final isGuest = currentUser == null || currentUser.isAnonymous;
    final canPostReview = !isGuest;

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ReviewsPalette.background,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ReviewsPalette.background.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ReviewsPalette.darkGold),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.landmark.name.toUpperCase(),
            style: const TextStyle(
              color: ReviewsPalette.darkGold,
              letterSpacing: 3.0,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocListener<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (!mounted) {
              return;
            }
            if (state is ReviewsError) {
              if (_isSubmitting) {
                setState(() => _isSubmitting = false);
              }
              if (_isDeleting) {
                setState(() => _isDeleting = false);
              }
              if (_isSubmitting || _isDeleting) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            }
            if (state is ReviewsLoaded && _isSubmitting) {
              _commentController.clear();
              _selectedRating = 0;
              setState(() => _isSubmitting = false);
            }
          },
          child: StreamBuilder<List<Review>>(
            stream: _reviewsStream,
            builder: (context, snapshot) {
              final reviews = snapshot.data ?? const <Review>[];
              _latestReviews = reviews;
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final isBlockingLoading = isLoading && reviews.isEmpty;
              final errorMessage = snapshot.hasError
                  ? 'Failed to load reviews.'
                  : null;
              final isBusy = isBlockingLoading || _isSubmitting;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroSection(),
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            _buildProtectedSection(
                              child: _buildRatingSummary(
                                reviews,
                                isBlockingLoading,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildRateSection(isBusy, canPostReview),
                            const SizedBox(height: 48),
                            _buildReviewersStrip(reviews, currentUserId),
                            const SizedBox(height: 24),
                            _buildReviewsHeader(),
                            const SizedBox(height: 24),
                            _buildReviewsBody(
                              reviews: reviews,
                              isLoading: isBlockingLoading,
                              errorMessage: errorMessage,
                              currentUserId: currentUserId,
                            ),
                            const SizedBox(height: 40),
                            //_buildLoadMoreButton(isLoading || _isSubmitting),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final heroUrl = widget.landmark.photos.isNotEmpty
        ? widget.landmark.photos.first.url
        : '';
    final isAsset = _isAssetPath(heroUrl);
    final isAppUrl = _isAppStorageUrl(heroUrl);

    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isAsset)
            Image.asset(
              heroUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildLandmarkPlaceholder(),
            )
          else if (isAppUrl)
            Image.network(
              heroUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildLandmarkPlaceholder(),
            )
          else
            _buildLandmarkPlaceholder(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  ReviewsPalette.background,
                  ReviewsPalette.background.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(List<Review> reviews, bool isLoading) {
    final stats = ReviewsStats.fromReviews(reviews);
    final averageText = isLoading ? '--' : stats.average.toStringAsFixed(1);
    final totalText = isLoading ? '--' : stats.total.toString();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ReviewsPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ReviewsPalette.divider.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 300;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: isWide ? 1 : 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          averageText,
                          style: const TextStyle(
                            fontSize: 56,
                            color: ReviewsPalette.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '/ 5',
                          style: TextStyle(
                            fontSize: 18,
                            color: ReviewsPalette.textMuted,
                          ),
                        ),
                      ],
                    ),
                    _buildAverageStars(stats.average),
                    const SizedBox(height: 8),
                    Text(
                      'Based on $totalText reviews',
                      style: const TextStyle(
                        color: ReviewsPalette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWide)
                const SizedBox(width: 32)
              else
                const SizedBox(height: 24),
              Expanded(
                flex: isWide ? 1 : 0,
                child: Column(
                  children: [
                    _buildRatingBar('5', stats.percentageFor(5)),
                    _buildRatingBar('4', stats.percentageFor(4)),
                    _buildRatingBar('3', stats.percentageFor(3)),
                    _buildRatingBar('2', stats.percentageFor(2)),
                    _buildRatingBar('1', stats.percentageFor(1)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAverageStars(double average) {
    final filled = average.round().clamp(0, 5);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Icon(
          index < filled ? Icons.star : Icons.star_border,
          color: ReviewsPalette.primaryGold,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRatingBar(String star, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text(
              star,
              style: TextStyle(
                color: percentage > 0.05
                    ? ReviewsPalette.textMuted
                    : ReviewsPalette.textMuted.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: const Color(0xFF383432),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  ReviewsPalette.primaryGold,
                ),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateSection(bool isLoading, bool canPost) {
    return _buildProtectedSection(
      child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ReviewsPalette.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ReviewsPalette.divider.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this Landmark',
            style: TextStyle(
              fontSize: 22,
              color: ReviewsPalette.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isFilled = starIndex <= _selectedRating;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: isLoading
                      ? null
                      : () => _requireAuth(context, () {
                            setState(() => _selectedRating = starIndex);
                          }),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    color: ReviewsPalette.darkGold,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            maxLines: 4,
            readOnly: !canPost,
            onTap: canPost ? null : () => _requireAuth(context, () {}),
            style: const TextStyle(color: ReviewsPalette.textMain),
            decoration: InputDecoration(
              hintText: 'Write your experience...',
              hintStyle: TextStyle(
                color: ReviewsPalette.textMuted.withOpacity(0.5),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ReviewsPalette.divider),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ReviewsPalette.primaryGold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [ReviewsPalette.primaryGold, ReviewsPalette.darkGold],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ReviewsPalette.primaryGold.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _requireAuth(context, _submitReview),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isLoading ? 'POSTING...' : 'POST REVIEW',
                  style: const TextStyle(
                    color: Color(0xFF432C00),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildReviewsHeader() {
    return _buildProtectedSection(
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ReviewsPalette.divider.withOpacity(0.3)),
          ),
        ),
        child: Column(
          // crossAxisAlignment.start تجعل العناصر تبدأ من جهة اليسار
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // السطر الأول: العنوان الأيسر
            const Text(
              'Visitor Experiences',
              style: TextStyle(fontSize: 26, color: ReviewsPalette.textMain),
            ),

            // مسافة عمودية صغيرة ومناسبة (4 بكسل) لجعل السطرين متقاربين
            const SizedBox(height: 4),

            // السطر الثاني: النص الفرعي الأيمن
            // استخدمنا Align لمحاذاة هذا النص تحديداً إلى جهة اليمين
            Align(
              alignment: Alignment.centerRight,
              child: const Text(
                'LATEST REVIEWS',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: ReviewsPalette.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewersStrip(List<Review> reviews, String? currentUserId) {
    final uniqueReviewers = <String, Review>{};
    for (final review in reviews) {
      uniqueReviewers.putIfAbsent(review.userId, () => review);
    }

    if (uniqueReviewers.isEmpty) {
      return const SizedBox.shrink();
    }

    final reviewers = uniqueReviewers.values.toList();

    return _buildProtectedSection(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ReviewsPalette.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ReviewsPalette.divider.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REVIEWERS',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2.0,
                color: ReviewsPalette.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: reviewers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final review = reviewers[index];
                  return _ReviewerAvatar(
                    key: ValueKey('reviewer-${review.userId}'),
                    imageUrl: review.userImage,
                    username: review.username,
                    onTap: () => _requireAuth(
                      context,
                      () => _openProfile(review.userId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsBody({
    required List<Review> reviews,
    required bool isLoading,
    required String? errorMessage,
    required String? currentUserId,
  }) {
    if (isLoading && reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: ReviewsPalette.primaryGold),
        ),
      );
    }

    if (errorMessage != null && reviews.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ReviewsPalette.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ReviewsPalette.divider.withOpacity(0.3)),
        ),
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.redAccent, fontSize: 14),
        ),
      );
    }

    if (reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: ReviewsPalette.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ReviewsPalette.divider.withOpacity(0.3)),
        ),
        child: const Text(
          'No reviews yet. Be the first to share your experience.',
          style: TextStyle(color: ReviewsPalette.textMuted, fontSize: 13),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < reviews.length; i++) ...[
          _buildReviewCard(review: reviews[i], currentUserId: currentUserId),
          if (i != reviews.length - 1) const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildReviewCard({
    required Review review,
    required String? currentUserId,
  }) {
    final timeAgo = _formatTimeAgo(review.createdAt);
    final roundedRating = review.rating.round().clamp(1, 5);
    final isOwner = currentUserId != null && review.userId == currentUserId;

    return _buildProtectedSection(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ReviewsPalette.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewerAvatar(
              key: ValueKey('reviewer-${review.userId}-${review.id}'),
              imageUrl: review.userImage,
              username: review.username,
              onTap: () => _requireAuth(
                context,
                () => _openProfile(review.userId),
              ),
              size: 56,
              borderWidth: 2,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _requireAuth(
                            context,
                            () => _openProfile(review.userId),
                          ),
                          child: Text(
                            review.username,
                            style: const TextStyle(
                              fontSize: 18,
                              color: ReviewsPalette.textMain,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          if (isOwner)
                            IconButton(
                              onPressed: _isDeleting
                                  ? null
                                  : () => _deleteReview(review),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: ReviewsPalette.textMuted,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.5,
                              color: ReviewsPalette.textMuted.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < roundedRating ? Icons.star : Icons.star_border,
                        color: index < roundedRating
                            ? ReviewsPalette.primaryGold
                            : ReviewsPalette.textMuted.withOpacity(0.2),
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    review.comment,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ReviewsPalette.textMuted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReview(Review review) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != review.userId) {
      return;
    }
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ReviewsPalette.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete review?',
          style: TextStyle(
            color: ReviewsPalette.textMain,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: ReviewsPalette.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: ReviewsPalette.textMuted,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: ReviewsPalette.primaryGold,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) {
      return;
    }
    final reviewsCubit = context.read<ReviewsCubit>();
    setState(() => _isDeleting = true);
    try {
      await reviewsCubit.deleteReview(
        reviewId: review.id,
        landmarkId: review.landmarkId,
        userId: review.userId,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete review.')),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() => _isDeleting = false);
    }
  }

  /*
  Widget _buildLoadMoreButton(bool isLoading) {
    return Center(
      child: TextButton(
        onPressed: isLoading
            ? null
            : () => context
                .read<ReviewsCubit>()
                .getReviewsForLandmark(widget.landmark.id),
        style: TextButton.styleFrom(
          foregroundColor: ReviewsPalette.primaryGold,
        ),
        child: const Text(
          'LOAD MORE STORIES',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
*/
  Future<void> _submitReview() async {
    if (_isSubmitting) {
      return;
    }
    if (_isGuest()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must login first to post a review')),
      );
      showJoinKemetDialog(context);
      return;
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must login first to post a review')),
      );
      showJoinKemetDialog(context);
      return;
    }

    final hasExistingReview = _latestReviews.any(
      (review) =>
          review.userId == currentUser.uid &&
          review.landmarkId == widget.landmark.id,
    );
    if (hasExistingReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already reviewed this landmark.')),
      );
      return;
    }

    final comment = _commentController.text.trim();
    if (_selectedRating == 0 || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a rating and a short review.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final reviewsCubit = context.read<ReviewsCubit>();
    setState(() => _isSubmitting = true);

    final review = Review(
      id: '',
      userId: currentUser.uid,
      username: currentUser.displayName?.trim().isNotEmpty == true
          ? currentUser.displayName!.trim()
          : (currentUser.email?.split('@').first ?? 'User'),
      userImage: null,
      landmarkId: widget.landmark.id,
      landmarkName: widget.landmark.name,
      comment: comment,
      rating: _selectedRating.toDouble(),
      createdAt: DateTime.now(),
    );

    debugPrint('Submitting review for landmarkId: ${review.landmarkId}');

    try {
      await reviewsCubit.addReview(review);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post review.')),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
    }
  }

  bool _isAssetPath(String value) {
    return value.startsWith('images/') || value.startsWith('assets/');
  }

  bool _isAppStorageUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return false;
    }
    if (uri.scheme == 'gs') {
      return true;
    }
    final host = uri.host.toLowerCase();
    return host.contains('firebasestorage.googleapis.com') ||
        host.contains('storage.googleapis.com');
  }


  Widget _buildLandmarkPlaceholder() {
    return Image.asset(
      'images/heroScreen.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: ReviewsPalette.surfaceHigh,
        child: const Center(
          child: Icon(
            Icons.account_balance,
            size: 90,
            color: ReviewsPalette.primaryGold,
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes.clamp(1, 59);
      return '$minutes MINUTES AGO';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} HOURS AGO';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} DAYS AGO';
    }
    final weeks = (diff.inDays / 7).floor();
    return '$weeks WEEKS AGO';
  }

  void _openProfile(String userId) {
    if (userId.isEmpty) {
      return;
    }
    requireAuthOrShowDialog(
      context,
      isGuest: _isGuest(),
      debugLabel: 'reviewer-open-profile-$userId',
      action: () {
        Navigator.of(context).pushNamed(Routes.profileScreen, arguments: userId);
      },
    );
  }

  bool _isGuest() {
    final user = FirebaseAuth.instance.currentUser;
    return user == null || user.isAnonymous;
  }

  void _requireAuth(BuildContext context, VoidCallback action) {
    requireAuthOrShowDialog(
      context,
      isGuest: _isGuest(),
      debugLabel: 'reviews-auth-guard',
      action: action,
    );
  }

  Widget _buildProtectedSection({required Widget child}) {
    final isGuest = _isGuest();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isGuest
          ? () => requireAuthOrShowDialog(
                context,
                isGuest: true,
                debugLabel: 'reviews-protected-section',
                action: () {},
              )
          : null,
      child: isGuest ? IgnorePointer(child: child) : child,
    );
  }

}

class _ReviewerAvatar extends StatelessWidget {
  const _ReviewerAvatar({
    super.key,
    required this.imageUrl,
    required this.username,
    required this.onTap,
    this.size = 48,
    this.borderWidth = 1.5,
  });

  final String? imageUrl;
  final String username;
  final VoidCallback onTap;
  final double size;
  final double borderWidth;

  static const String _placeholderAsset = 'images/logo.png';

  String? _sanitizeUserImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    if (url.contains('googleusercontent.com')) return null;

    if (_isAssetPath(url) || _isAppStorageUrl(url) || url.startsWith('http')) {
      return url;
    }

    return null;
  }

  bool _isAssetPath(String value) {
    return value.startsWith('images/') || value.startsWith('assets/');
  }

  bool _isAppStorageUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return false;
    }
    if (uri.scheme == 'gs') {
      return true;
    }
    final host = uri.host.toLowerCase();
    return host.contains('firebasestorage.googleapis.com') ||
        host.contains('storage.googleapis.com');
  }

  @override
  Widget build(BuildContext context) {
    return _buildAvatar(
      photoUrl: _sanitizeUserImageUrl(imageUrl) ?? '',
      displayName: username.trim().isNotEmpty ? username.trim() : 'User',
    );
  }

  Widget _buildAvatar({
    required String photoUrl,
    required String displayName,
  }) {

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ReviewsPalette.darkGold.withOpacity(0.3),
                width: borderWidth,
              ),
            ),
            child: ClipOval(
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 8,
            child: Text(
              displayName.isNotEmpty ? displayName : 'User',
              style: const TextStyle(
                color: ReviewsPalette.textMuted,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      _placeholderAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildInitials('?'),
    );
  }

  Widget _buildInitials(String initials) {
    return Container(
      color: ReviewsPalette.surfaceHigh,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: ReviewsPalette.primaryGold,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}

class ReviewsPalette {
  static const Color background = Color(0xFF161311);
  static const Color surfaceContainer = Color(0xFF1E1B19);
  static const Color surfaceHigh = Color(0xFF221F1D);
  static const Color primaryGold = Color(0xFFEBC07E);
  static const Color darkGold = Color(0xFFC59D5F);
  static const Color textMain = Color(0xFFE9E1DD);
  static const Color textMuted = Color(0xFFD2C4B5);
  static const Color divider = Color(0xFF4E4539);
}

class ReviewsStats {
  ReviewsStats({
    required this.average,
    required this.total,
    required this.starCounts,
  });

  final double average;
  final int total;
  final Map<int, int> starCounts;

  double percentageFor(int star) {
    if (total == 0) {
      return 0;
    }
    return (starCounts[star] ?? 0) / total;
  }

  factory ReviewsStats.fromReviews(List<Review> reviews) {
    if (reviews.isEmpty) {
      return ReviewsStats(average: 0, total: 0, starCounts: const {});
    }

    double sum = 0;
    final counts = <int, int>{};
    for (final review in reviews) {
      sum += review.rating;
      final star = review.rating.round().clamp(1, 5);
      counts[star] = (counts[star] ?? 0) + 1;
    }

    return ReviewsStats(
      average: sum / reviews.length,
      total: reviews.length,
      starCounts: counts,
    );
  }
}
