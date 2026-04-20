import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NarrationState {
  const NarrationState({
    required this.sentences,
    required this.wordPrefixPerSentence,
    required this.currentTime,
    required this.totalTime,
    required this.isPlaying,
    required this.isPaused,
    required this.currentSentenceIndex,
    required this.currentWordIndex,
    required this.totalWords,
  });

  factory NarrationState.initial() {
    return const NarrationState(
      sentences: <String>[],
      wordPrefixPerSentence: <int>[],
      currentTime: Duration.zero,
      totalTime: Duration.zero,
      isPlaying: false,
      isPaused: false,
      currentSentenceIndex: 0,
      currentWordIndex: 0,
      totalWords: 0,
    );
  }

  final List<String> sentences;
  final List<int> wordPrefixPerSentence;
  final Duration currentTime;
  final Duration totalTime;
  final bool isPlaying;
  final bool isPaused;
  final int currentSentenceIndex;
  final int currentWordIndex;
  final int totalWords;

  int get totalSentences => sentences.length;

  double get sentenceProgress {
    if (totalSentences <= 1) {
      return 0;
    }
    return currentSentenceIndex / (totalSentences - 1);
  }

  double get wordProgress {
    if (totalWords <= 1) {
      return 0;
    }
    return currentWordIndex / (totalWords - 1);
  }

  Duration get currentPositionEstimate {
    if (totalTime == Duration.zero) {
      return Duration.zero;
    }
    return currentTime;
  }

  String get currentPositionLabel {
    final current = currentPositionEstimate;
    final minutes = current.inMinutes;
    final seconds = current.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get estimatedDurationLabel {
    if (totalTime == Duration.zero) {
      return '--:--';
    }
    final totalSeconds = totalTime.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get currentTimeLabel {
    final currentSeconds = currentTime.inSeconds;
    final minutes = currentSeconds ~/ 60;
    final seconds = currentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get totalTimeLabel => estimatedDurationLabel;

  NarrationState copyWith({
    List<String>? sentences,
    List<int>? wordPrefixPerSentence,
    Duration? currentTime,
    Duration? totalTime,
    bool? isPlaying,
    bool? isPaused,
    int? currentSentenceIndex,
    int? currentWordIndex,
    int? totalWords,
  }) {
    return NarrationState(
      sentences: sentences ?? this.sentences,
      wordPrefixPerSentence:
          wordPrefixPerSentence ?? this.wordPrefixPerSentence,
      currentTime: currentTime ?? this.currentTime,
      totalTime: totalTime ?? this.totalTime,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      currentSentenceIndex: currentSentenceIndex ?? this.currentSentenceIndex,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      totalWords: totalWords ?? this.totalWords,
    );
  }
}

class NarrationTTSController extends ChangeNotifier {
  NarrationTTSController._({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  static final NarrationTTSController instance = NarrationTTSController._();

  static final RegExp _arabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
  );

  final FlutterTts _flutterTts;
  final ValueNotifier<NarrationState> stateNotifier = ValueNotifier(
    NarrationState.initial(),
  );

  bool _isInitialized = false;
  int _sessionId = 0;
  int _currentSentenceIndex = 0;
  int _currentWordIndex = 0;
  int _totalWords = 0;
  int _pausedSentenceIndex = 0;
  String _lastLanguage = 'en-US';
  List<String> _sentences = const <String>[];
  List<int> _wordPrefixPerSentence = const <int>[];
  List<int> _sentenceDurationsMs = const <int>[];
  int _currentElapsedMs = 0;
  Timer? _progressTimer;
  bool _isCommandInFlight = false;

  bool get isSpeaking => stateNotifier.value.isPlaying;
  bool get isPaused => stateNotifier.value.isPaused;
  int get currentIndex => stateNotifier.value.currentSentenceIndex;
  Duration get currentTime => stateNotifier.value.currentTime;
  Duration get totalTime => stateNotifier.value.totalTime;
  List<String> get sentences => stateNotifier.value.sentences;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setLanguage(_lastLanguage);

    _flutterTts.setErrorHandler((message) {
      debugPrint('NarrationTTSService error: $message');
      _stopProgressTimer();
      _updateState(isPlaying: false, isPaused: false);
    });

    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    if (_isCommandInFlight) {
      return;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _isCommandInFlight = true;
    try {
      await init();
      await _prepareNarration(trimmed);
      _currentElapsedMs = 0;
      await _playFromSentence(
        0,
        resetState: true,
        startPosition: Duration.zero,
      );
    } finally {
      _isCommandInFlight = false;
    }
  }

  Future<void> pause() async {
    if (!isSpeaking) {
      return;
    }

    final pausedSentenceIndex = _currentSentenceIndex;
    final pausedWordIndex = _currentWordIndex;

    try {
      _sessionId++;
      _stopProgressTimer();
      await _flutterTts.stop();
    } catch (_) {
      // Some engines may already have stopped; preserve progress either way.
    }

    _pausedSentenceIndex = pausedSentenceIndex;
    _updateState(
      isPlaying: false,
      isPaused: true,
      currentSentenceIndex: pausedSentenceIndex,
      currentWordIndex: pausedWordIndex,
      currentTime: Duration(milliseconds: _currentElapsedMs),
    );
  }

  Future<void> resume() async {
    if (!isPaused || _sentences.isEmpty) {
      return;
    }
    _isCommandInFlight = true;
    try {
      await init();
      await _playFromSentence(
        _pausedSentenceIndex,
        resetState: false,
        startPosition: Duration(milliseconds: _currentElapsedMs),
      );
    } finally {
      _isCommandInFlight = false;
    }
  }

  Future<void> stop() async {
    _sessionId++;
    _stopProgressTimer();
    await _flutterTts.stop();
    _currentSentenceIndex = 0;
    _currentWordIndex = 0;
    _pausedSentenceIndex = 0;
    _currentElapsedMs = 0;
    _updateState(
      isPlaying: false,
      isPaused: false,
      currentSentenceIndex: 0,
      currentWordIndex: 0,
      currentTime: Duration.zero,
    );
  }

  Future<void> seekToSentence(int targetIndex) async {
    if (_sentences.isEmpty) {
      return;
    }

    final clamped = targetIndex.clamp(0, _sentences.length - 1);
    final targetTime = Duration(milliseconds: _sentenceStartForIndex(clamped));
    await seekToTime(targetTime);
  }

  Future<void> seekToTime(Duration targetTime) async {
    if (_sentences.isEmpty) {
      return;
    }

    final clampedMs = targetTime.inMilliseconds.clamp(
      0,
      totalTime.inMilliseconds,
    );
    final clamped = Duration(milliseconds: clampedMs);
    final sentenceIndex = _sentenceIndexForElapsed(clampedMs);

    _pausedSentenceIndex = sentenceIndex;
    _currentSentenceIndex = sentenceIndex;
    _currentWordIndex = _wordPrefixForSentence(sentenceIndex);
    _currentElapsedMs = clampedMs;

    _updateState(
      currentSentenceIndex: _currentSentenceIndex,
      currentWordIndex: _currentWordIndex,
      currentTime: clamped,
    );

    if (isSpeaking) {
      _sessionId++;
      _stopProgressTimer();
      await _flutterTts.stop();
      await _playFromSentence(
        sentenceIndex,
        resetState: false,
        startPosition: clamped,
      );
      return;
    }
  }

  void previewSeekToTime(Duration targetTime) {
    if (_sentences.isEmpty) {
      return;
    }

    final clampedMs = targetTime.inMilliseconds.clamp(
      0,
      totalTime.inMilliseconds,
    );
    final clamped = Duration(milliseconds: clampedMs);
    final sentenceIndex = _sentenceIndexForElapsed(clampedMs);

    _pausedSentenceIndex = sentenceIndex;
    _currentSentenceIndex = sentenceIndex;
    _currentWordIndex = _wordPrefixForSentence(sentenceIndex);
    _currentElapsedMs = clampedMs;

    _updateState(
      currentSentenceIndex: _currentSentenceIndex,
      currentWordIndex: _currentWordIndex,
      currentTime: clamped,
    );
  }

  void previewSeekToSentence(int targetIndex) {
    if (_sentences.isEmpty) {
      return;
    }

    final clamped = targetIndex.clamp(0, _sentences.length - 1);
    _currentSentenceIndex = clamped;
    _currentWordIndex = _wordPrefixForSentence(clamped);
    _pausedSentenceIndex = clamped;
    _currentElapsedMs = _sentenceStartForIndex(clamped);

    _updateState(
      currentSentenceIndex: _currentSentenceIndex,
      currentWordIndex: _currentWordIndex,
      currentTime: Duration(milliseconds: _currentElapsedMs),
    );
  }

  Future<void> _prepareNarration(String rawText) async {
    final normalized = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();
    final baseSentences = _splitSentences(normalized);
    final processedSentences = baseSentences
        .map(_preprocessForNarration)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    _sentences = processedSentences;
    _wordPrefixPerSentence = _buildWordPrefixes(processedSentences);
    _sentenceDurationsMs = _buildSentenceDurations(processedSentences);
    _totalWords = _wordPrefixPerSentence.isNotEmpty
        ? _wordPrefixPerSentence.last + _countWords(processedSentences.last)
        : 0;
    final estimatedTotalMs = _sentenceDurationsMs.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    _currentSentenceIndex = 0;
    _currentWordIndex = 0;
    _pausedSentenceIndex = 0;
    _currentElapsedMs = 0;

    _updateState(
      sentences: _sentences,
      wordPrefixPerSentence: _wordPrefixPerSentence,
      totalTime: Duration(milliseconds: estimatedTotalMs),
      currentTime: Duration.zero,
      currentSentenceIndex: 0,
      currentWordIndex: 0,
      totalWords: _totalWords,
      isPlaying: false,
      isPaused: false,
    );
  }

  Future<void> _playFromSentence(
    int startIndex, {
    required bool resetState,
    required Duration startPosition,
  }) async {
    if (_sentences.isEmpty) {
      return;
    }

    final int session = ++_sessionId;
    await _flutterTts.stop();

    _currentSentenceIndex = startIndex.clamp(0, _sentences.length - 1);
    _currentWordIndex = _wordPrefixForSentence(_currentSentenceIndex);
    _pausedSentenceIndex = _currentSentenceIndex;
    _currentElapsedMs = startPosition.inMilliseconds.clamp(
      0,
      totalTime.inMilliseconds,
    );
    _updateState(
      isPlaying: true,
      isPaused: false,
      currentSentenceIndex: _currentSentenceIndex,
      currentWordIndex: _currentWordIndex,
      currentTime: Duration(milliseconds: _currentElapsedMs),
    );
    _startProgressTimer();

    for (var i = _currentSentenceIndex; i < _sentences.length; i++) {
      if (session != _sessionId) {
        return;
      }

      final sentence = _sentences[i];
      final language = _detectLanguage(sentence);
      if (language != _lastLanguage) {
        await _flutterTts.setLanguage(language);
        _lastLanguage = language;
      }

      _currentSentenceIndex = i;
      _currentWordIndex = _wordPrefixForSentence(i);
      _updateState(
        currentSentenceIndex: _currentSentenceIndex,
        currentWordIndex: _currentWordIndex,
      );

      await _flutterTts.speak(sentence);
    }

    if (session == _sessionId) {
      _stopProgressTimer();
      _currentSentenceIndex = _sentences.length - 1;
      _currentWordIndex = _totalWords > 0 ? _totalWords - 1 : 0;
      _currentElapsedMs = totalTime.inMilliseconds;
      _updateState(
        isPlaying: false,
        isPaused: false,
        currentSentenceIndex: _currentSentenceIndex,
        currentWordIndex: _currentWordIndex,
        currentTime: totalTime,
      );
      if (resetState) {
        _pausedSentenceIndex = 0;
      }
    }
  }

  List<String> _splitSentences(String text) {
    final matches = RegExp(r'[^.!?؟…]+[.!?؟…]*').allMatches(text);
    final parts = matches
        .map((match) => match.group(0)?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty && text.isNotEmpty) {
      return <String>[text];
    }
    return parts;
  }

  String _detectLanguage(String text) {
    return _arabicRegex.hasMatch(text) ? 'ar-SA' : 'en-US';
  }

  String _preprocessForNarration(String text) {
    var normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    normalized = normalized.replaceAll(RegExp(r'\.\s*'), '... ');
    normalized = normalized.replaceAll(',', ', ... ');
    normalized = normalized.replaceAll('،', '، ... ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  List<int> _buildWordPrefixes(List<String> sentences) {
    final prefixes = <int>[];
    var runningCount = 0;
    for (final sentence in sentences) {
      prefixes.add(runningCount);
      runningCount += _countWords(sentence);
    }
    return prefixes;
  }

  List<int> _buildSentenceDurations(List<String> sentences) {
    return sentences.map(_estimateSentenceDurationMs).toList(growable: false);
  }

  int _countWords(String text) {
    return RegExp(r'\S+').allMatches(text).length;
  }

  int _estimateSentenceDurationMs(String sentence) {
    final words = _countWords(sentence);
    if (words <= 0) {
      return 0;
    }
    const wordsPerMinute = 120;
    const basePauseMs = 250;
    final wordsMs = (words * 60000 / wordsPerMinute).round();
    final punctuationBonusMs = sentence.contains(RegExp(r'[.!?…]')) ? 250 : 0;
    final commaBonusMs = sentence.contains(RegExp(r'[,،]')) ? 180 : 0;
    return wordsMs + basePauseMs + punctuationBonusMs + commaBonusMs;
  }

  int _sentenceStartForIndex(int sentenceIndex) {
    if (_sentenceDurationsMs.isEmpty) {
      return 0;
    }

    var total = 0;
    for (var i = 0; i < sentenceIndex && i < _sentenceDurationsMs.length; i++) {
      total += _sentenceDurationsMs[i];
    }
    return total;
  }

  int _sentenceIndexForElapsed(int elapsedMs) {
    if (_sentenceDurationsMs.isEmpty) {
      return 0;
    }

    var running = 0;
    for (var i = 0; i < _sentenceDurationsMs.length; i++) {
      running += _sentenceDurationsMs[i];
      if (elapsedMs < running) {
        return i;
      }
    }

    return _sentenceDurationsMs.length - 1;
  }

  void _startProgressTimer() {
    _stopProgressTimer();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!isSpeaking) {
        return;
      }

      final nextElapsed = (_currentElapsedMs + 300).clamp(
        0,
        totalTime.inMilliseconds,
      );
      _currentElapsedMs = nextElapsed;

      _updateState(currentTime: Duration(milliseconds: _currentElapsedMs));

      if (_currentElapsedMs >= totalTime.inMilliseconds &&
          totalTime != Duration.zero) {
        timer.cancel();
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  int _wordPrefixForSentence(int sentenceIndex) {
    if (_wordPrefixPerSentence.isEmpty) {
      return 0;
    }
    return _wordPrefixPerSentence[sentenceIndex.clamp(
      0,
      _wordPrefixPerSentence.length - 1,
    )];
  }

  void _updateState({
    List<String>? sentences,
    List<int>? wordPrefixPerSentence,
    Duration? currentTime,
    Duration? totalTime,
    bool? isPlaying,
    bool? isPaused,
    int? currentSentenceIndex,
    int? currentWordIndex,
    int? totalWords,
  }) {
    final oldState = stateNotifier.value;
    final nextState = oldState.copyWith(
      sentences: sentences,
      wordPrefixPerSentence: wordPrefixPerSentence,
      currentTime: currentTime,
      totalTime: totalTime,
      isPlaying: isPlaying,
      isPaused: isPaused,
      currentSentenceIndex: currentSentenceIndex,
      currentWordIndex: currentWordIndex,
      totalWords: totalWords,
    );
    final unchanged =
        oldState.isPlaying == nextState.isPlaying &&
        oldState.isPaused == nextState.isPaused &&
        oldState.currentSentenceIndex == nextState.currentSentenceIndex &&
        oldState.currentWordIndex == nextState.currentWordIndex &&
        oldState.totalWords == nextState.totalWords &&
        oldState.currentTime == nextState.currentTime &&
        oldState.totalTime == nextState.totalTime &&
        listEquals(oldState.sentences, nextState.sentences) &&
        listEquals(
          oldState.wordPrefixPerSentence,
          nextState.wordPrefixPerSentence,
        );
    if (unchanged) {
      return;
    }
    stateNotifier.value = nextState;
    notifyListeners();
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _flutterTts.stop();
    _stopProgressTimer();
    stateNotifier.dispose();
    super.dispose();
  }
}

@Deprecated('Use NarrationTTSController instead.')
class NarrationTTSService {
  NarrationTTSService._();

  static NarrationTTSController get instance => NarrationTTSController.instance;
}

typedef NarrationController = NarrationTTSController;
