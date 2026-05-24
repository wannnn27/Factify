import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputButton extends StatefulWidget {
  final ValueChanged<String> onResult;
  final ValueChanged<bool>? onListeningChanged;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.onListeningChanged,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isInitializing = false;
  late AnimationController _animationController;

  String _currentRecognizedWords = '';
  String _lastEmittedWords = '';
  String _selectedLocaleId = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechEnabled) return true;
    if (_isInitializing) return false;

    setState(() => _isInitializing = true);

    try {
      final available = await _speechToText.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
        debugLogging: false,
      );

      if (!mounted) return false;

      _speechEnabled = available;
      if (available) {
        _selectedLocaleId = await _resolvePreferredLocale();
      } else {
        _showSnackBar(
          'Voice input tidak tersedia. Pastikan izin mikrofon aktif dan layanan speech recognition tersedia.',
        );
      }
    } catch (e) {
      debugPrint('Speech to text initialize failed: $e');
      if (mounted) {
        _showSnackBar('Gagal mengaktifkan voice input: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }

    return _speechEnabled;
  }

  Future<String> _resolvePreferredLocale() async {
    try {
      final locales = await _speechToText.locales();

      String normalize(String value) =>
          value.toLowerCase().replaceAll('-', '_');

      String? exactMatch(String target) {
        final normalizedTarget = normalize(target);
        for (final locale in locales) {
          if (normalize(locale.localeId) == normalizedTarget) {
            return locale.localeId;
          }
        }
        return null;
      }

      String? languageMatch(String languageCode) {
        for (final locale in locales) {
          final normalizedLocale = normalize(locale.localeId);
          if (normalizedLocale == languageCode ||
              normalizedLocale.startsWith('${languageCode}_')) {
            return locale.localeId;
          }
        }
        return null;
      }

      final systemLocale = await _speechToText.systemLocale();

      return exactMatch('id_ID') ??
          languageMatch('id') ??
          exactMatch('en_US') ??
          languageMatch('en') ??
          systemLocale?.localeId ??
          '';
    } catch (e) {
      debugPrint('Failed to resolve speech locale: $e');
      return '';
    }
  }

  Future<void> _toggleListening() async {
    if (_speechToText.isListening) {
      await _stopListening();
      return;
    }

    await _startListening();
  }

  Future<void> _startListening() async {
    final ready = await _ensureSpeechReady();
    if (!ready) return;

    _currentRecognizedWords = '';
    _lastEmittedWords = '';
    widget.onListeningChanged?.call(true);
    _animationController.repeat(reverse: true);

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          autoPunctuation: true,
        ).copyWith(
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 5),
          localeId: _selectedLocaleId,
        ),
      );
    } catch (e) {
      debugPrint('Speech to text listen failed: $e');
      widget.onListeningChanged?.call(false);
      _animationController.stop();
      _animationController.value = 0;
      _showSnackBar('Voice input gagal dimulai: $e');
    }

    if (mounted) setState(() {});
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (mounted) setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (words.isEmpty || words == _lastEmittedWords) return;

    _currentRecognizedWords = words;
    _lastEmittedWords = words;
    widget.onResult(words);

    if (mounted) setState(() {});
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech to text status: $status');
    if (status == 'done' || status == 'notListening') {
      _finishListening();
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    debugPrint('Speech to text error: $error');
    _finishListening();

    final errorText = error.errorMsg.toLowerCase();
    if (error.permanent ||
        errorText.contains('not_allowed') ||
        errorText.contains('permission')) {
      _showSnackBar(
          'Izin mikrofon ditolak. Aktifkan izin mikrofon untuk memakai voice input.');
    } else if (errorText.contains('recognizer') ||
        errorText.contains('not_available')) {
      _showSnackBar('Speech recognition tidak tersedia di perangkat ini.');
    } else {
      _showSnackBar(
          'Suara belum terbaca. Coba bicara lebih jelas lalu ulangi.');
    }
  }

  void _finishListening() {
    if (_currentRecognizedWords.isNotEmpty &&
        _currentRecognizedWords != _lastEmittedWords) {
      widget.onResult(_currentRecognizedWords);
    }

    _currentRecognizedWords = '';
    _lastEmittedWords = '';
    widget.onListeningChanged?.call(false);
    _animationController.stop();
    _animationController.value = 0;

    if (mounted) setState(() {});
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isListening = _speechToText.isListening;

    return Tooltip(
      message: isListening ? 'Stop voice input' : 'Mulai voice input',
      child: InkResponse(
        onTap: _isInitializing ? null : _toggleListening,
        radius: 24,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final pulse = 0.2 + (_animationController.value * 0.3);

            return Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening
                    ? Colors.red.withValues(alpha: pulse)
                    : const Color(0xFF1E232C),
                border: Border.all(
                  color: isListening ? Colors.red : const Color(0xFF00C9A7),
                  width: 1,
                ),
              ),
              child: Center(
                child: _isInitializing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00C9A7),
                        ),
                      )
                    : Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color:
                            isListening ? Colors.red : const Color(0xFF00C9A7),
                        size: 22,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
