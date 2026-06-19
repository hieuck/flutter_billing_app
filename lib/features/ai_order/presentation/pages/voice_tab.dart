import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import '../bloc/ai_order_bloc.dart';

class VoiceTab extends StatefulWidget {
  const VoiceTab({super.key});

  @override
  State<VoiceTab> createState() => _VoiceTabState();
}

class _VoiceTabState extends State<VoiceTab> {
  bool _isListening = false;
  String _transcript = '';

  void _startListening() {
    setState(() {
      _isListening = true;
      _transcript = '';
    });
  }

  void _stopListening() {
    setState(() => _isListening = false);
    if (_transcript.isNotEmpty) {
      context.read<AiOrderBloc>().add(ParseTextEvent(_transcript));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTapDown: (_) => _startListening(),
            onTapUp: (_) => _stopListening(),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : Colors.grey[300],
              ),
              child: Icon(
                Icons.mic,
                size: 60,
                color: _isListening ? Colors.white : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isListening ? 'Listening...' : 'Tap and hold to speak',
            style: const TextStyle(fontSize: 16),
          ),
          if (_transcript.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(_transcript,
                style: const TextStyle(fontSize: 18)),
          ],
        ],
      ),
    );
  }
}
