import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/services/text_to_speech_service.dart';

class NarrationPlayerPanel extends StatefulWidget {
  const NarrationPlayerPanel({
    super.key,
    required this.controller,
    required this.title,
    required this.text,
  });

  final NarrationTTSController controller;
  final String title;
  final String text;

  @override
  State<NarrationPlayerPanel> createState() => _NarrationPlayerPanelState();
}

class _NarrationPlayerPanelState extends State<NarrationPlayerPanel> {
  double? _scrubValue;
  bool _isScrubbing = false;

  NarrationTTSController get _tts => widget.controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NarrationState>(
      valueListenable: _tts.stateNotifier,
      builder: (context, state, _) {
        final totalSentences = state.totalSentences;
        final totalTimeMs = state.totalTime.inMilliseconds;
        final canSeek = totalTimeMs > 0;
        final visualIndex = _isScrubbing
            ? (_scrubValue ?? state.currentTime.inMilliseconds.toDouble())
            : state.currentTime.inMilliseconds.toDouble();
        final clampedTime = visualIndex.clamp(
          0.0,
          canSeek ? totalTimeMs.toDouble() : 0.0,
        );
        final positionLabel = state.currentTimeLabel;
        final durationLabel = state.totalTimeLabel;
        final isPlaying = state.isPlaying;
        final isPaused = state.isPaused;
        final canResumeFromPosition =
            canSeek && state.currentTime > Duration.zero;
        final sentenceLabel = context.tr(
          'sentence_progress',
          args: {
            'current': '${state.currentSentenceIndex + 1}',
            'total': '$totalSentences',
          },
        );
        final readyLabel = context.tr('narration_ready');

        void handlePlay() {
          if (canResumeFromPosition) {
            _tts.playFromPosition(widget.text, state.currentTime);
            return;
          }
          _tts.speak(widget.text);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            final buttonWidth = compact
                ? ((constraints.maxWidth - 8) / 2).clamp(140.0, 240.0)
                : ((constraints.maxWidth - 24) / 4).clamp(110.0, 180.0);

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.mainGold.withValues(alpha: 0.16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.32),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEBC07E), Color(0xFFC59D5F)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainGold.withValues(alpha: 0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying ? Icons.graphic_eq : Icons.music_note,
                          color: AppColors.textDarkOnGold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSerif(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              canSeek ? sentenceLabel : readyLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSerif(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _PlayPauseButton(
                        isPlaying: isPlaying,
                        isPaused: isPaused,
                        onPlay: handlePlay,
                        onPause: isPlaying ? _tts.pause : null,
                        onResume: isPaused ? _tts.resume : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          positionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        durationLabel,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 7,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 11,
                          pressedElevation: 10,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 18,
                        ),
                        activeTrackColor: AppColors.mainGold,
                        inactiveTrackColor: const Color(0x33EBC07E),
                        thumbColor: AppColors.mainGold,
                        overlayColor: AppColors.mainGold.withValues(
                          alpha: 0.16,
                        ),
                      ),
                      child: Slider(
                        value: canSeek ? clampedTime : 0,
                        min: 0,
                        max: canSeek ? totalTimeMs.toDouble() : 1,
                        onChangeStart: canSeek
                            ? (value) {
                                setState(() {
                                  _isScrubbing = true;
                                  _scrubValue = value;
                                });
                              }
                            : null,
                        onChanged: canSeek
                            ? (value) {
                                setState(() {
                                  _scrubValue = value;
                                });
                                _tts.previewSeekToTime(
                                  Duration(milliseconds: value.round()),
                                );
                              }
                            : null,
                        onChangeEnd: canSeek
                            ? (value) async {
                                setState(() {
                                  _isScrubbing = false;
                                  _scrubValue = null;
                                });
                                await _tts.seekToTime(
                                  Duration(milliseconds: value.round()),
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: buttonWidth,
                        child: _PlayerActionButton(
                          label: context.tr('play'),
                          icon: Icons.play_arrow,
                          enabled: !isPlaying && !isPaused,
                          onPressed: handlePlay,
                          filled: true,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _PlayerActionButton(
                          label: context.tr('pause'),
                          icon: Icons.pause,
                          enabled: isPlaying,
                          onPressed: _tts.pause,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _PlayerActionButton(
                          label: context.tr('resume'),
                          icon: Icons.play_circle_outline,
                          enabled: isPaused,
                          onPressed: _tts.resume,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _PlayerActionButton(
                          label: context.tr('stop'),
                          icon: Icons.stop,
                          enabled: isPlaying || isPaused,
                          onPressed: _tts.stop,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isPaused,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
  });

  final bool isPlaying;
  final bool isPaused;
  final VoidCallback onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPlaying ? onPause : (isPaused ? onResume : onPlay),
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFEBC07E), Color(0xFFC59D5F)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainGold.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textDarkOnGold),
        ),
      ),
    );
  }
}

class _PlayerActionButton extends StatelessWidget {
  const _PlayerActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final background = filled ? AppColors.mainGold : const Color(0xFF1C1C1C);
    final foreground = filled ? AppColors.textDarkOnGold : Colors.white;
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: const Color(0xFF232323),
          disabledForegroundColor: Colors.white38,
          elevation: 0,
          side: BorderSide(color: filled ? Colors.transparent : Colors.white12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
