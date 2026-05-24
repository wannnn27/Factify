import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:speech_to_text/speech_to_text_web.dart';

void ensureSpeechToTextWebRegistered() {
  SpeechToTextPlugin.registerWith(webPluginRegistrar);
}
