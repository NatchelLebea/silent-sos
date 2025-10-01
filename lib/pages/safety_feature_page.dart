import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SafetyFeaturePage extends StatefulWidget {
  const SafetyFeaturePage({super.key});

  @override
  State<SafetyFeaturePage> createState() => _SafetyFeaturePageState();
}

class _SafetyFeaturePageState extends State<SafetyFeaturePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String? _triggerWord;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadTriggerWord();
  }

  Future<void> _loadTriggerWord() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _triggerWord = prefs.getString('trigger_word');
    });
  }

  Future<void> _startListening() async {
    if (_triggerWord == null || _triggerWord!.isEmpty) {
      _showDialog("Error", "No trigger word set. Please set it first.");
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" && _isListening) {
          _restartListening(); // Keep listening continuously
        }
      },
      onError: (error) {
        debugPrint("Speech error: $error");
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          String spoken = result.recognizedWords.trim().toLowerCase();
          if (spoken.contains(_triggerWord!.toLowerCase())) {
            _showDialog("SOS Triggered", "Your SOS trigger word was detected!");
            _stopListening(); // Stop after detected once
          }
        },
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      _showDialog("Error", "Speech recognition not available.");
    }
  }

  void _restartListening() {
    if (_isListening) {
      _speech.stop();
      Future.delayed(const Duration(milliseconds: 500), () {
        _speech.listen(
          onResult: (result) {
            String spoken = result.recognizedWords.trim().toLowerCase();
            if (spoken.contains(_triggerWord!.toLowerCase())) {
              _showDialog("SOS Triggered", "Your SOS trigger word was detected!");
              _stopListening();
            }
          },
          listenMode: stt.ListenMode.confirmation,
        );
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 100,
                  color: Color(0xFF00B050),
                ),
                const SizedBox(height: 32),
                Text(
                  'Hi There,',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you ok, safety is our priority',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text(_isListening ? 'Listening...' : 'Enable Safety Feature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B050),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _isListening ? null : _startListening,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                    label: const Text('Disable Safety Feature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _isListening ? _stopListening : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
