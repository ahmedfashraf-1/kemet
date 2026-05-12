import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/core/services/arabic_local_description_service.dart';
import 'package:kemet/core/widgets/join_kemet_dialog.dart';
import 'package:kemet/core/utils/share_service.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/services/text_to_speech_service.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';
import 'package:kemet/features/landmarks/presentation/widgets/discover_more_section.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_description_section.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_gallery.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_hero_section.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_info_card.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_map_button.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_bottom_nav_bar.dart';
import 'package:kemet/features/notifications/data/datasources/local_notification.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_cubit.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_state.dart';
import 'package:url_launcher/url_launcher.dart';

class LandmarkDetailsScreen extends StatefulWidget {
  const LandmarkDetailsScreen({super.key, required this.landmark});

  final Landmark landmark;

  @override
  State<LandmarkDetailsScreen> createState() => _LandmarkDetailsScreenState();
}

class _LandmarkDetailsScreenState extends State<LandmarkDetailsScreen>
    with WidgetsBindingObserver, RouteAware {
  late final NarrationTTSController _ttsService;
  ModalRoute<dynamic>? _route;
  String _descriptionText = '';
  String? _descriptionLocaleCode;
  bool _isResolvingDescription = false;
  DateTime? _lastDescriptionAttempt;

  @override
  void initState() {
    super.initState();
    _ttsService = NarrationTTSController.instance;
    _descriptionText = '';
    WidgetsBinding.instance.addObserver(this);
    unawaited(_ttsService.stop());
    _saveToRecentTrips();
    _initializeTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveLocalizedDescription();
    final route = ModalRoute.of(context);
    if (_route != route) {
      if (_route is PageRoute<dynamic>) {
        routeObserver.unsubscribe(this);
      }
      _route = route;
      if (route is PageRoute<dynamic>) {
        routeObserver.subscribe(this, route);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);

    _ttsService.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    try {
      await _ttsService.init();
    } catch (_) {
      // Keep details page usable even if TTS setup fails on a device.
    }
  }

  Future<void> _toggleListen(String text) async {
    if (_ttsService.isSpeaking) {
      await _ttsService.pause();
      return;
    }
    if (_ttsService.isPaused) {
      await _ttsService.resume();
      return;
    }
    await _ttsService.speak(text);
  }

  Future<void> _resolveLocalizedDescription() async {
    final localeCode = Localizations.localeOf(context).languageCode;
    final needsRefresh = _descriptionLocaleCode != localeCode;
    if (!needsRefresh || _isResolvingDescription) {
      return;
    }

    _descriptionLocaleCode = localeCode;
    final baseText = widget.landmark.description.trim();
    if (localeCode != 'ar') {
      if (mounted) {
        setState(() {
          _descriptionText = baseText;
        });
      }
      _isResolvingDescription = true;
      try {
        final now = DateTime.now();
        if (_lastDescriptionAttempt != null &&
            now.difference(_lastDescriptionAttempt!).inSeconds < 2) {
          return;
        }
        _lastDescriptionAttempt = now;

        final repository = context.read<LandmarksRepository>();
        final result = await repository.getLandmarkById(
          widget.landmark.id,
          languageCode: localeCode,
        );
        final localized = result.fold((_) => null, (landmark) => landmark);
        final fetchedText = localized?.description.trim() ?? '';
        if (fetchedText.isNotEmpty &&
            !_isUnavailableDescription(fetchedText) &&
            mounted) {
          setState(() {
            _descriptionText = fetchedText;
          });
          unawaited(_ttsService.preparePreview(_descriptionText));
        } else {
          unawaited(_ttsService.preparePreview(_descriptionText));
        }
      } finally {
        _isResolvingDescription = false;
      }
      return;
    }

    _isResolvingDescription = true;
    try {
      final now = DateTime.now();
      if (_lastDescriptionAttempt != null &&
          now.difference(_lastDescriptionAttempt!).inSeconds < 2) {
        return;
      }
      _lastDescriptionAttempt = now;

      final localDescription = await ArabicLocalDescriptionService.instance
          .getDescriptionForXid(widget.landmark.id);
      final resolved = (localDescription ?? '').trim();

      if (mounted) {
        setState(() {
          _descriptionText = resolved.isNotEmpty ? resolved : baseText;
        });
      }
      unawaited(_ttsService.preparePreview(_descriptionText));
    } finally {
      _isResolvingDescription = false;
    }
  }

  bool _isUnavailableDescription(String text) {
    final lowered = text.trim().toLowerCase();
    return lowered.isEmpty ||
        lowered == 'no description available' ||
        lowered == 'no description provided' ||
        lowered == 'unknown' ||
        lowered == 'description not available';
  }

  @override
  void didPushNext() {
    _ttsService.pause();
  }

  @override
  void didPopNext() {}

  @override
  void didPop() {
    _ttsService.stop();
  }

  @override
  void didPush() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _ttsService.pause();
    }
  }

  Future<void> _saveToRecentTrips() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final xid = widget.landmark.id;
      if (xid.isEmpty) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'recentTrips': FieldValue.arrayUnion([xid]),
      }, SetOptions(merge: true));
      LocalNotificationService.instance.showLandmarkViewedNotification(
        landmarkName: widget.landmark.name,
        city: widget.landmark.city,
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final landmark = widget.landmark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final descriptionText = localeCode == 'ar'
        ? (_descriptionText.isNotEmpty
              ? _descriptionText
              : landmark.description)
        : (_descriptionText.isNotEmpty
              ? _descriptionText
              : landmark.description);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 64.0;
    const extraBottom = 24.0;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isGuest = firebaseUser == null || firebaseUser.isAnonymous;

    void openReviews() {
      final opened = requireAuthOrShowDialog(
        context,
        isGuest: isGuest,
        debugLabel: 'landmark-details-open-reviews',
        action: () {
          Navigator.of(
            context,
          ).pushNamed(Routes.reviewsScreen, arguments: landmark);
        },
      );
      if (!opened) return;
    }

    Future<void> openMap() async {
      final lat = landmark.latitude;
      final lng = landmark.longitude;
      if (lat == null || lng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location is unavailable.')),
        );
        return;
      }
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!context.mounted) {
        return;
      }
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open Google Maps.')),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              _ttsService.stop();
            }
          },
          child: Stack(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  final eased = Curves.easeOutCubic.transform(value);
                  return Transform.translate(
                    offset: Offset(0, 16 * (1 - eased)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Hero section (image + overlay + top actions).
                    SliverToBoxAdapter(
                      child: BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, favState) {
                          final isFav = favState is FavoritesLoaded
                              ? favState.favoriteIds.contains(landmark.id)
                              : false;

                          return LandmarkHeroSection(
                            landmark: landmark,
                            isFavorite: isFav,
                            onBack: () => Navigator.of(context).pop(),
                            onShare: (context) =>
                                shareLandmark(context, landmark),
                            onFavorite: () => context
                                .read<FavoritesCubit>()
                                .toggle(landmark.id),
                          );
                        },
                      ),
                    ),

                    // Description section with narrative and audio button (UI only).
                    SliverToBoxAdapter(
                      child: _SectionFadeSlide(
                        child: LandmarkDescriptionSection(
                          landmark: landmark,
                          descriptionOverride: descriptionText,
                        ),
                      ),
                    ),

                    // Visiting hours info card.
                    SliverToBoxAdapter(
                      child: _SectionFadeSlide(
                        child: LandmarkInfoCard(landmark: landmark),
                      ),
                    ),

                    // Map call to action (UI only).
                    SliverToBoxAdapter(
                      child: _SectionFadeSlide(
                        child: LandmarkMapButton(
                          city: landmark.city,
                          latitude: landmark.latitude,
                          longitude: landmark.longitude,
                        ),
                      ),
                    ),

                    // Horizontal gallery.
                    SliverToBoxAdapter(
                      child: LandmarkGallery(photos: landmark.photos),
                    ),

                    // Discover more cards (derived from the landmark data).
                    SliverToBoxAdapter(
                      child: DiscoverMoreSection(landmark: landmark),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: barHeight + bottomInset + extraBottom,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LandmarkBottomNavBar(
                  activeIndex: 0,
                  bottomInset: bottomInset,
                  showReviews: true,
                  onMapTap: openMap,
                  onAudioTap: () {
                    // The audio action is wired here so the bottom navigation icon can
                    // control the same landmark narration as the main description button.
                    _toggleListen(descriptionText);
                  },
                  onReviews: openReviews,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionFadeSlide extends StatelessWidget {
  const _SectionFadeSlide({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, child) {
        final eased = Curves.easeOut.transform(value);
        return Transform.translate(
          offset: Offset(0, 14 * (1 - eased)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}
