import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  final FlutterTts _tts = FlutterTts();

  TtsHelper() {
    _tts.setLanguage('vi-VN');
    _tts.setSpeechRate(0.5);
  }

  Future<void> announcePayment(double amount) async {
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    await _tts.speak('Đã nhận $formatted đồng');
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}
