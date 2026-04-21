import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/services/text_to_speech_service.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/presentation/widgets/narration_player_panel.dart';

class LandmarkDescriptionSection extends StatelessWidget {
  const LandmarkDescriptionSection({
    super.key,
    required this.landmark,
    this.descriptionOverride,
  });

  final Landmark landmark;
  final String? descriptionOverride;

  @override
  Widget build(BuildContext context) {
    final tts = NarrationTTSController.instance;
    final descriptionText = descriptionOverride ?? landmark.description;

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
                      context.tr('narrative_title'),
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
                RichText(
                  text: TextSpan(
                    children: _buildNarrationSpans(
                      state,
                      fallbackText: descriptionText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                NarrationPlayerPanel(
                  controller: tts,
                  title: landmark.name,
                  text: descriptionText,
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
    final isNarrating = state.isPlaying || state.isPaused;
    if (state.sentences.isEmpty || !isNarrating) {
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
    final baseStyle = GoogleFonts.notoSerif(
      fontSize: 16,
      height: 1.75,
      fontWeight: FontWeight.w300,
      color: Colors.white70,
    );

    var globalWordIndex = 0;

    for (
      var sentenceIndex = 0;
      sentenceIndex < state.sentences.length;
      sentenceIndex++
    ) {
      final sentence = state.sentences[sentenceIndex];
      final isSentenceActive =
          isNarrating && sentenceIndex == state.currentSentenceIndex;
      final tokens = RegExp(r'\S+|\s+').allMatches(sentence);

      for (final match in tokens) {
        final token = match.group(0) ?? '';
        if (token.trim().isEmpty) {
          spans.add(TextSpan(text: token, style: baseStyle));
          continue;
        }

        final isCurrentWord =
            isNarrating && globalWordIndex == state.currentWordIndex;
        final wordStyle = baseStyle.copyWith(
          fontWeight: isCurrentWord
              ? FontWeight.w700
              : (isSentenceActive ? FontWeight.w600 : FontWeight.w300),
          color: isCurrentWord
              ? AppColors.mainGold
              : (isSentenceActive ? Colors.white : Colors.white70),
          backgroundColor: isCurrentWord
              ? AppColors.mainGold.withValues(alpha: 0.22)
              : (isSentenceActive
                    ? AppColors.mainGold.withValues(alpha: 0.08)
                    : Colors.transparent),
        );

        spans.add(TextSpan(text: token, style: wordStyle));
        globalWordIndex++;
      }

      spans.add(TextSpan(text: ' ', style: baseStyle));
    }

    return spans;
  }
}
