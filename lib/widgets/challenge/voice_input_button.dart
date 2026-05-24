import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onResult;

  const VoiceInputButton({super.key, required this.onResult});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize the speech to text plugin
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        debugPrint('Speech to text error: $error');
        if (mounted) setState(() {});
      },
      onStatus: (status) {
        debugPrint('Speech to text status: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() {});
        }
      },
    );
    if (mounted) setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if (!_speechEnabled) {
      _initSpeech();
      return;
    }

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        localeId: 'id_ID',
      ),
    );
    if (mounted) setState(() {});
  }

  /// Manually stop the active speech recognition session
  void _stopListening() async {
    await _speechToText.stop();
    if (mounted) setState(() {});
  }

  /// Callback that is called whenever speech is recognized
  void _onSpeechResult(SpeechRecognitionResult result) {
    // Only send result when it's final
    if (result.finalResult) {
       widget.onResult(result.recognizedWords);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isListening = _speechToText.isListening;

    return GestureDetector(
      onTapDown: (_) {
        if (_speechEnabled) {
           _startListening();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin mikrofon diperlukan atau fitur tidak didukung.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      onTapUp: (_) {
         if (isListening) {
           _stopListening();
         }
      },
      onTapCancel: () {
         if (isListening) {
           _stopListening();
         }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening 
                  ? Colors.red.withValues(alpha: 0.2 + (_animationController.value * 0.3)) 
                  : Colors.transparent,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening ? Colors.red : const Color(0xFF00C9A7),
              size: 24,
            ),
          );
        },
      ),
    );
  }
}
