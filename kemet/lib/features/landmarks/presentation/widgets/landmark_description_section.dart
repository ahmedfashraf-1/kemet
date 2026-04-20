import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/services/text_to_speech_service.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/presentation/widgets/narration_player_panel.dart';

class LandmarkDescriptionSection extends StatelessWidget {
  const LandmarkDescriptionSection({super.key, required this.landmark});

  final Landmark landmark;

  @override
  Widget build(BuildContext context) {
    final tts = NarrationTTSController.instance;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.mainGold.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ValueListenableBuilder<NarrationState>(
          valueListenable: tts.stateNotifier,
          builder: (context, state, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state.isPlaying || state.isPaused
                            ? AppColors.mainGold
                            : AppColors.darkGold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'The Narrative',
                      style: GoogleFonts.notoSerif(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: AppColors.mainGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: RichText(
                    key: ValueKey(
                      '${state.currentSentenceIndex}-${state.currentWordIndex}-${state.isPlaying}-${state.isPaused}',
                    ),
                    text: TextSpan(
                      children: _buildNarrationSpans(
                        state,
                        fallbackText: landmark.description,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                NarrationPlayerPanel(
                  controller: tts,
                  title: landmark.name,
                  text: landmark.description,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<InlineSpan> _buildNarrationSpans(
    NarrationState state, {
    required String fallbackText,
  }) {
    if (state.sentences.isEmpty) {
      return <InlineSpan>[
        TextSpan(
          text: fallbackText,
          style: GoogleFonts.notoSerif(
            fontSize: 16,
            height: 1.75,
            fontWeight: FontWeight.w300,
            color: Colors.white70,
          ),
        ),
      ];
    }

    final spans = <InlineSpan>[];
    final isNarrating = state.isPlaying || state.isPaused;

    for (
      var sentenceIndex = 0;
      sentenceIndex < state.sentences.length;
      sentenceIndex++
    ) {
      final sentence = state.sentences[sentenceIndex];
      final isSentenceActive =
          isNarrating && sentenceIndex == state.currentSentenceIndex;

      spans.add(
        TextSpan(
          text: '$sentence ',
          style: GoogleFonts.notoSerif(
            fontSize: 16,
            height: 1.75,
            fontWeight: isSentenceActive ? FontWeight.w700 : FontWeight.w300,
            color: isSentenceActive ? AppColors.mainGold : Colors.white70,
            backgroundColor: isSentenceActive
                ? AppColors.mainGold.withValues(alpha: 0.16)
                : Colors.transparent,
          ),
        ),
      );
    }

    return spans;
  }
}
