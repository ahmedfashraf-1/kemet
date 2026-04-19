import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/widgets/join_kemet_dialog.dart';
import 'package:kemet/core/utils/share_service.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/services/text_to_speech_service.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
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

class _LandmarkDetailsScreenState extends State<LandmarkDetailsScreen> {
  late final TextToSpeechService _ttsService;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _progress = 0.0;
  bool _isScrubbing = false;

  @override
  void initState() {
    super.initState();
    _ttsService = FlutterTextToSpeechService.instance;
    _ttsService.addListener(_syncPlaybackState);
    _saveToRecentTrips();
    _initializeTts();
  }

  @override
  void dispose() {
    _ttsService.removeListener(_syncPlaybackState);
    FlutterTextToSpeechService.instance.stop();
    super.dispose();
  }

  void _syncPlaybackState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isPlaying = _ttsService.isPlaying;
      _isPaused = _ttsService.isPaused;
      if (!_isScrubbing) {
        _progress = _ttsService.progress;
      }
    });
  }

  Future<void> _initializeTts() async {
    try {
      await FlutterTextToSpeechService.instance.initialize(
        defaultLanguage: 'en-US',
        speechRate: 0.46,
        pitch: 1.02,
        languageMode: TtsLanguageMode.auto,
      );
      _syncPlaybackState();
    } catch (_) {
      // Keep details page usable even if TTS setup fails on a device.
    }
  }

  Future<void> _toggleListen(String text) async {
    await _ttsService.togglePlayPause(text);
  }

  Future<void> _seek(String text, double value) async {
    await _ttsService.seekToFraction(text, value);
  }

  int _estimateTotalSeconds(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (words == 0) {
      return 0;
    }
    const baseWpm = 160.0;
    final rate = _ttsService.speechRate <= 0 ? 0.5 : _ttsService.speechRate;
    final effectiveWpm = baseWpm * (rate / 0.5);
    final seconds = (words / effectiveWpm) * 60.0;
    return seconds.round().clamp(1, 24 * 60 * 60);
  }

  String _formatSeconds(int seconds) {
    final clamped = seconds.clamp(0, 24 * 60 * 60);
    final minutesPart = clamped ~/ 60;
    final secondsPart = clamped % 60;
    final minutesText = minutesPart.toString().padLeft(2, '0');
    final secondsText = secondsPart.toString().padLeft(2, '0');
    return '$minutesText:$secondsText';
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
    const timelineHeight = 84.0;
    final showTimeline = _isPlaying || _isPaused || _isScrubbing;
    final extraBottom = showTimeline ? timelineHeight + 16 : 24.0;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isGuest = firebaseUser == null || firebaseUser.isAnonymous;
    final totalSeconds = _estimateTotalSeconds(landmark.description);
    final currentSeconds = totalSeconds == 0
        ? 0
        : (totalSeconds * _progress).round().clamp(0, totalSeconds);

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
                      child: LandmarkDescriptionSection(landmark: landmark),
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
            if (showTimeline)
              Positioned(
                left: 16,
                right: 16,
                bottom: bottomInset + barHeight + 12,
                child: _LandmarkAudioTimeline(
                  enabled: true,
                  value: _progress,
                  isPlaying: _isPlaying,
                  currentTime: _formatSeconds(currentSeconds),
                  totalTime: totalSeconds == 0
                      ? '--:--'
                      : _formatSeconds(totalSeconds),
                  onPlayPause: () => _toggleListen(landmark.description),
                  onChangeStart: () {
                    setState(() {
                      _isScrubbing = true;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _progress = value;
                    });
                  },
                  onChangeEnd: (value) async {
                    setState(() {
                      _isScrubbing = false;
                      _progress = value;
                    });
                    await _seek(landmark.description, value);
                  },
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
                  _toggleListen(landmark.description);
                },
                onReviews: openReviews,
              ),
            ),
          ],
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

class _LandmarkAudioTimeline extends StatelessWidget {
  const _LandmarkAudioTimeline({
    required this.enabled,
    required this.value,
    required this.isPlaying,
    required this.currentTime,
    required this.totalTime,
    required this.onPlayPause,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final bool enabled;
  final double value;
  final bool isPlaying;
  final String currentTime;
  final String totalTime;
  final VoidCallback onPlayPause;
  final VoidCallback onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.subtleGoldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? onPlayPause : null,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.inputBackground,
                  border: Border.all(color: AppColors.mainGold),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.mainGold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentTime,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      totalTime,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.mainGold,
                    inactiveTrackColor: AppColors.mainGold.withValues(
                      alpha: 0.25,
                    ),
                    thumbColor: AppColors.mainGold,
                    overlayColor: AppColors.mainGold.withValues(alpha: 0.2),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: value.clamp(0.0, 1.0),
                    onChangeStart: enabled ? (_) => onChangeStart() : null,
                    onChanged: enabled ? onChanged : null,
                    onChangeEnd: enabled ? onChangeEnd : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
