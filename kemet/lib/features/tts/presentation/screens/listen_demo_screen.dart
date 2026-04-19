import 'package:flutter/material.dart';
import 'package:kemet/core/services/text_to_speech_service.dart';

class ListenDemoScreen extends StatefulWidget {
  const ListenDemoScreen({super.key, this.text = _defaultText});

  static const String _defaultText =
      'Welcome to Kemet. Tap the Listen button to hear this description in a calm, elegant voice.';

  final String text;

  @override
  State<ListenDemoScreen> createState() => _ListenDemoScreenState();
}

class _ListenDemoScreenState extends State<ListenDemoScreen> {
  static const Color _pageBackground = Color(0xFF0F0F0F);
  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _textPrimary = Color(0xFFF2E9D8);
  static const Color _textMuted = Color(0xFFC9BCA1);

  late final TextToSpeechService _ttsService;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isInitializing = true;
  TtsLanguageMode _languageMode = TtsLanguageMode.auto;
  String _activeLanguage = 'en-US';

  @override
  void initState() {
    super.initState();
    _ttsService = FlutterTextToSpeechService.instance;
    _ttsService.addListener(_syncPlaybackState);
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      await _ttsService.initialize(
        defaultLanguage: 'en-US',
        speechRate: 0.46,
        pitch: 1.02,
        languageMode: TtsLanguageMode.auto,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isPlaying = _ttsService.isPlaying;
          _isPaused = _ttsService.isPaused;
          _languageMode = _ttsService.languageMode;
          _activeLanguage = _ttsService.activeLanguage;
        });
      }
    }
  }

  void _syncPlaybackState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isPlaying = _ttsService.isPlaying;
      _isPaused = _ttsService.isPaused;
      _languageMode = _ttsService.languageMode;
      _activeLanguage = _ttsService.activeLanguage;
    });
  }

  @override
  void dispose() {
    _ttsService.removeListener(_syncPlaybackState);
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (_isInitializing) {
      return;
    }
    await _ttsService.togglePlayPause(widget.text);
  }

  Future<void> _stop() async {
    if (_isInitializing) {
      return;
    }
    await _ttsService.stop();
  }

  Future<void> _setLanguageMode(TtsLanguageMode mode) async {
    await _ttsService.setLanguageMode(mode);
    if (!mounted) {
      return;
    }
    setState(() {
      _languageMode = mode;
      _activeLanguage = _ttsService.activeLanguage;
    });
  }

  IconData _playbackIcon() {
    if (_isPlaying) {
      return Icons.pause;
    }
    if (_isPaused) {
      return Icons.play_arrow;
    }
    return Icons.volume_up;
  }

  String _playbackLabel() {
    if (_isInitializing) {
      return 'INITIALIZING...';
    }
    if (_isPlaying) {
      return 'PAUSE';
    }
    if (_isPaused) {
      return 'RESUME';
    }
    return 'LISTEN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _gold),
        title: const Text(
          'LISTEN',
          style: TextStyle(
            color: _gold,
            letterSpacing: 3,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _gold.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium audio guide',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: _textMuted.withValues(alpha: 0.95),
                        height: 1.7,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _LanguageModeSelector(
                selected: _languageMode,
                onChanged: _setLanguageMode,
                gold: _gold,
              ),
              const SizedBox(height: 16),
              Text(
                'Voice: $_activeLanguage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textMuted.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: _toggleListen,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _isPlaying
                                  ? _gold
                                  : _gold.withValues(alpha: 0.8),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    ),
                                child: Icon(
                                  _playbackIcon(),
                                  key: ValueKey<String>(
                                    '$_isPlaying$_isPaused',
                                  ),
                                  color: _gold,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: Text(
                                  _playbackLabel(),
                                  key: ValueKey<String>(_playbackLabel()),
                                  style: const TextStyle(
                                    color: _gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _stop,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _surface,
                            border: Border.all(
                              color: _gold.withValues(alpha: 0.75),
                            ),
                          ),
                          child: Icon(
                            Icons.stop,
                            color: _gold.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _isPlaying
                    ? 'Audio is playing. Tap pause to continue later.'
                    : (_isPaused
                        ? 'Audio paused. Tap resume to continue.'
                        : 'Tap listen to hear the text aloud.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textMuted.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageModeSelector extends StatelessWidget {
  const _LanguageModeSelector({
    required this.selected,
    required this.onChanged,
    required this.gold,
  });

  final TtsLanguageMode selected;
  final ValueChanged<TtsLanguageMode> onChanged;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _modeChip(
          mode: TtsLanguageMode.auto,
          label: 'AUTO',
        ),
        _modeChip(
          mode: TtsLanguageMode.english,
          label: 'EN',
        ),
        _modeChip(
          mode: TtsLanguageMode.arabic,
          label: 'AR',
        ),
      ],
    );
  }

  Widget _modeChip({required TtsLanguageMode mode, required String label}) {
    final active = selected == mode;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF2C1D00) : gold,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      selected: active,
      onSelected: (_) => onChanged(mode),
      selectedColor: gold,
      backgroundColor: const Color(0xFF1A1A1A),
      side: BorderSide(color: gold.withValues(alpha: active ? 0.0 : 0.6)),
      shape: const StadiumBorder(),
    );
  }
}

