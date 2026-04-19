import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsPlaybackState { idle, playing, paused }

enum TtsLanguageMode { auto, english, arabic }

/// Abstraction over the speech backend so the app can swap Flutter TTS for a
/// remote provider later (for example, ElevenLabs) without changing the UI.
abstract class TextToSpeechService extends Listenable {
  bool get isPlaying;
  bool get isPaused;
  TtsPlaybackState get playbackState;
  double get speechRate;
  double get pitch;
  String get activeLanguage;
  TtsLanguageMode get languageMode;

  Future<void> initialize({
    String defaultLanguage,
    double speechRate,
    double pitch,
    TtsLanguageMode languageMode,
  });

  Future<void> play(String text);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> togglePlayPause(String text);
  Future<void> setLanguageMode(TtsLanguageMode mode);

  // Backward-compatible aliases.
  Future<void> speak(String text);
  Future<void> toggle(String text);
  void dispose();
}

class FlutterTextToSpeechService extends ChangeNotifier
    implements TextToSpeechService {
  /// Shared app-wide controller so audio buttons can reflect the same state.
  static final FlutterTextToSpeechService instance =
      FlutterTextToSpeechService();

  FlutterTextToSpeechService({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  static final RegExp _arabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
  );

  bool _initialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _pauseRequested = false;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  String _activeLanguage = 'en-US';
  TtsLanguageMode _languageMode = TtsLanguageMode.auto;
  String _lastText = '';
  int _resumeOffset = 0;

  @override
  bool get isPlaying => _isPlaying;

  @override
  bool get isPaused => _isPaused;

  @override
  TtsPlaybackState get playbackState {
    if (_isPlaying) {
      return TtsPlaybackState.playing;
    }
    if (_isPaused) {
      return TtsPlaybackState.paused;
    }
    return TtsPlaybackState.idle;
  }

  @override
  double get speechRate => _speechRate;

  @override
  double get pitch => _pitch;

  @override
  String get activeLanguage => _activeLanguage;

  @override
  TtsLanguageMode get languageMode => _languageMode;

  @override
  Future<void> initialize({
    String defaultLanguage = 'en-US',
    double speechRate = 0.5,
    double pitch = 1.0,
    TtsLanguageMode languageMode = TtsLanguageMode.auto,
  }) async {
    _activeLanguage = defaultLanguage;
    _speechRate = speechRate;
    _pitch = pitch;
    _languageMode = languageMode;

    if (_initialized) {
      await _applyConfiguration();
      return;
    }

    await _applyConfiguration();

    _flutterTts.setStartHandler(() {
      _pauseRequested = false;
      _setState(playing: true, paused: false);
    });

    _flutterTts.setProgressHandler((text, startOffset, endOffset, word) {
      if (text == _lastText && endOffset >= 0 && endOffset <= text.length) {
        _resumeOffset = endOffset;
      }
    });

    _flutterTts.setCompletionHandler(() {
      _setState(playing: false, paused: false, resetProgress: true);
    });

    _flutterTts.setCancelHandler(() {
      if (_pauseRequested) {
        _pauseRequested = false;
        _setState(playing: false, paused: true);
        return;
      }
      _setState(playing: false, paused: false, resetProgress: true);
    });

    _flutterTts.setErrorHandler((_) {
      _pauseRequested = false;
      _setState(playing: false, paused: false, resetProgress: true);
    });

    _initialized = true;
  }

  Future<void> _applyConfiguration() async {
    await _flutterTts.setLanguage(_activeLanguage);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(1.0);
  }

  @override
  Future<void> play(String text) async {
    final sanitized = text.trim();
    if (sanitized.isEmpty) {
      return;
    }

    await initialize(
      defaultLanguage: _activeLanguage,
      speechRate: _speechRate,
      pitch: _pitch,
      languageMode: _languageMode,
    );

    // Safety: prevent overlapping playback by canceling any in-progress audio.
    if (_isPlaying || _isPaused) {
      await stop();
    }

    _lastText = sanitized;
    _resumeOffset = 0;
    _pauseRequested = false;
    _activeLanguage = await _resolveLanguageForText(sanitized);
    await _applyConfiguration();

    _setState(playing: true, paused: false);
    try {
      await _flutterTts.speak(sanitized);
    } catch (_) {
      _setState(playing: false, paused: false, resetProgress: true);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    if (!_isPlaying) {
      return;
    }

    // flutter_tts pause support differs by engine/platform. We always use a
    // safe fallback by stopping, then resume from last progress offset.
    _pauseRequested = true;
    await _flutterTts.stop();
    _setState(playing: false, paused: true);
  }

  @override
  Future<void> resume() async {
    if (!_isPaused || _lastText.trim().isEmpty) {
      return;
    }

    final safeOffset = _resumeOffset.clamp(0, _lastText.length);
    final remaining = _lastText.substring(safeOffset).trim();
    if (remaining.isEmpty) {
      _setState(playing: false, paused: false, resetProgress: true);
      return;
    }

    _pauseRequested = false;
    _setState(playing: true, paused: false);
    try {
      await _applyConfiguration();
      await _flutterTts.speak(remaining);
    } catch (_) {
      _setState(playing: false, paused: false, resetProgress: true);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    _pauseRequested = false;
    await _flutterTts.stop();
    _setState(playing: false, paused: false, resetProgress: true);
  }

  @override
  Future<void> togglePlayPause(String text) async {
    if (_isPlaying) {
      await pause();
      return;
    }
    if (_isPaused) {
      await resume();
      return;
    }
    await play(text);
  }

  @override
  Future<void> setLanguageMode(TtsLanguageMode mode) async {
    _languageMode = mode;
    if (!_initialized) {
      return;
    }
    if (_lastText.trim().isNotEmpty) {
      _activeLanguage = await _resolveLanguageForText(_lastText);
      await _applyConfiguration();
    }
    notifyListeners();
  }

  @override
  Future<void> speak(String text) => play(text);

  @override
  Future<void> toggle(String text) async {
    await togglePlayPause(text);
  }

  Future<String> _resolveLanguageForText(String text) async {
    final preferred = switch (_languageMode) {
      TtsLanguageMode.english => 'en-US',
      TtsLanguageMode.arabic => 'ar-EG',
      TtsLanguageMode.auto => _arabicRegex.hasMatch(text) ? 'ar-EG' : 'en-US',
    };

    final available = await _tryGetLanguages();
    if (available.isEmpty) {
      return preferred;
    }

    final normalized = available
        .map((e) => e.toLowerCase().replaceAll('_', '-'))
        .toList(growable: false);

    String? pick(List<String> candidates) {
      for (final candidate in candidates) {
        final key = candidate.toLowerCase().replaceAll('_', '-');
        final idx = normalized.indexOf(key);
        if (idx >= 0) {
          return available[idx];
        }
      }
      return null;
    }

    if (preferred.startsWith('ar')) {
      return pick(const ['ar-EG', 'ar-SA']) ??
          pick(available.where((e) => e.toLowerCase().startsWith('ar')).toList()) ??
          preferred;
    }

    return pick(const ['en-US']) ??
        pick(available.where((e) => e.toLowerCase().startsWith('en')).toList()) ??
        preferred;
  }

  Future<List<String>> _tryGetLanguages() async {
    try {
      final result = await _flutterTts.getLanguages;
      if (result is List) {
        return result.map((e) => e.toString()).toList(growable: false);
      }
    } catch (_) {
      // Ignore language discovery failures and keep preferred fallback.
    }
    return const <String>[];
  }

  void _setState({
    required bool playing,
    required bool paused,
    bool resetProgress = false,
  }) {
    if (_isPlaying == playing && _isPaused == paused && !resetProgress) {
      return;
    }

    _isPlaying = playing;
    _isPaused = paused;

    if (resetProgress) {
      _lastText = '';
      _resumeOffset = 0;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _flutterTts.stop();
    super.dispose();
  }
}



