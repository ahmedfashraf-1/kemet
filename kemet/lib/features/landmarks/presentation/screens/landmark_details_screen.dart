import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/app_router.dart';
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

class LandmarkDetailsScreen extends StatefulWidget {
  const LandmarkDetailsScreen({super.key, required this.landmark});

  final Landmark landmark;

  @override
  State<LandmarkDetailsScreen> createState() => _LandmarkDetailsScreenState();
}

class _LandmarkDetailsScreenState extends State<LandmarkDetailsScreen>
    with WidgetsBindingObserver, RouteAware {
  static final RegExp _arabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
  );

  late final NarrationTTSController _ttsService;
  ModalRoute<dynamic>? _route;
  String _descriptionText = '';
  String? _descriptionLocaleCode;
  bool _isResolvingDescription = false;
  Timer? _descriptionRetry;
  DateTime? _lastDescriptionAttempt;

  @override
  void initState() {
    super.initState();
    _ttsService = NarrationTTSController.instance;
    _descriptionText = widget.landmark.description;
    WidgetsBinding.instance.addObserver(this);
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
    _descriptionRetry?.cancel();
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
    if (_descriptionLocaleCode == localeCode || _isResolvingDescription) {
      return;
    }

    _descriptionLocaleCode = localeCode;
    final baseText = widget.landmark.description.trim();
    if (localeCode != 'ar') {
      _descriptionRetry?.cancel();
      if (mounted) {
        setState(() {
          _descriptionText = baseText;
        });
      }
      return;
    }

    if (_isMostlyArabic(baseText)) {
      if (mounted) {
        setState(() {
          _descriptionText = baseText;
        });
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

      final repository = context.read<LandmarksRepository>();
      final result = await repository.getLandmarkById(
        widget.landmark.id,
        languageCode: 'ar',
      );
      final localized = result.fold((_) => null, (landmark) => landmark);
      final arabicFromApi = localized?.description.trim() ?? '';
      if (_isMostlyArabic(arabicFromApi)) {
        if (mounted) {
          setState(() {
            _descriptionText = arabicFromApi;
          });
        }
        return;
      }

      final translated = await _translateToArabic(baseText);
      if (translated != null && mounted) {
        setState(() {
          _descriptionText = translated;
        });
      }
    } finally {
      _isResolvingDescription = false;
    }

    if (mounted && !_isMostlyArabic(_descriptionText)) {
      _descriptionRetry?.cancel();
      _descriptionRetry = Timer(
        const Duration(seconds: 2),
        _resolveLocalizedDescription,
      );
    }
  }

  bool _isMostlyArabic(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final arabicCount = _countMatches(trimmed, _arabicRegex);
    final latinCount = _countMatches(trimmed, RegExp(r'[A-Za-z]'));
    final total = arabicCount + latinCount;
    if (total == 0) {
      return false;
    }
    return arabicCount / total >= 0.4;
  }

  int _countMatches(String text, RegExp pattern) {
    return pattern.allMatches(text).length;
  }

  Future<String?> _translateToArabic(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    try {
      final chunks = _splitIntoChunks(trimmed, maxLength: 900);
      final buffer = StringBuffer();
      for (final chunk in chunks) {
        final translatedChunk = await _translateChunkToArabic(chunk);
        if (translatedChunk == null) {
          return null;
        }
        if (buffer.isNotEmpty) {
          buffer.write(' ');
        }
        buffer.write(translatedChunk);
      }
      final translated = buffer.toString().trim();
      if (translated.isEmpty || !_isMostlyArabic(translated)) {
        return null;
      }
      return translated;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _translateChunkToArabic(String chunk) async {
    final uri = Uri.https('translate.googleapis.com', '/translate_a/single');
    final response = await http
        .post(
          uri,
          headers: const {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          },
          body: {
            'client': 'gtx',
            'sl': 'en',
            'tl': 'ar',
            'dt': 't',
            'q': chunk,
          },
        )
        .timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body);
    if (data is! List || data.isEmpty) {
      return null;
    }

    final segments = data[0];
    if (segments is! List) {
      return null;
    }

    final buffer = StringBuffer();
    for (final segment in segments) {
      if (segment is List && segment.isNotEmpty && segment[0] is String) {
        buffer.write(segment[0] as String);
      }
    }

    final translated = buffer.toString().trim();
    if (translated.isEmpty) {
      return null;
    }
    return translated;
  }

  List<String> _splitIntoChunks(String text, {required int maxLength}) {
    if (text.length <= maxLength) {
      return [text];
    }

    final parts = <String>[];
    var remaining = text.trim();
    while (remaining.length > maxLength) {
      var splitIndex = remaining.lastIndexOf(RegExp(r'[.!?\n]'), maxLength);
      if (splitIndex <= 0) {
        splitIndex = remaining.lastIndexOf(' ', maxLength);
      }
      if (splitIndex <= 0) {
        splitIndex = maxLength;
      }
      parts.add(remaining.substring(0, splitIndex).trim());
      remaining = remaining.substring(splitIndex).trim();
    }

    if (remaining.isNotEmpty) {
      parts.add(remaining);
    }

    return parts;
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
                      child: LandmarkHeroSection(
                        landmark: landmark,
                        onBack: () => Navigator.of(context).pop(),
                        onShare: (context) => shareLandmark(context, landmark),
                      ),
                    ),

                    // Description section with narrative and audio button (UI only).
                    SliverToBoxAdapter(
                      child: _SectionFadeSlide(
                        child: LandmarkDescriptionSection(
                          landmark: landmark,
                          descriptionOverride: _descriptionText,
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
                  activeIndex: 1,
                  bottomInset: bottomInset,
                  showReviews: true,
                  onAudioTap: () {
                    // The audio action is wired here so the bottom navigation icon can
                    // control the same landmark narration as the main description button.
                    _toggleListen(_descriptionText);
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
