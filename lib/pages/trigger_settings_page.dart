import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

class TriggerSettingsPage extends StatefulWidget {
  const TriggerSettingsPage({super.key});

  @override
  State<TriggerSettingsPage> createState() => _TriggerSettingsPageState();
}

class _TriggerSettingsPageState extends State<TriggerSettingsPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<String> _recordings = [];
  String? _finalWord;
  String _message = "Press to record your trigger word";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadSavedTriggerWord();
  }

  Future<void> _loadSavedTriggerWord() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedWord = prefs.getString('trigger_word');
    if (savedWord != null) {
      setState(() {
        _finalWord = savedWord;
        _message = "Trigger word already set: $savedWord";
      });
    }
  }

  Future<void> _startRecording() async {
    bool available = await _speech.initialize();
    if (!available) return;

    setState(() {
      _isListening = true;
      _message = "Recording for 2 seconds...";
    });

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _handleRecordedWord(result.recognizedWords);
        }
      },
    );

    // Stop after 2 seconds
    Timer(const Duration(seconds: 2), () {
      _stopRecording();
    });
  }

  void _stopRecording() {
    _speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _handleRecordedWord(String word) async {
    String recorded = word.trim().toLowerCase();

    if (recorded.isEmpty) {
      setState(() => _message = "Didn’t catch that. Please try again.");
      return;
    }

    _recordings.add(recorded);

    if (_recordings.length == 2) {
      if (_recordings[0] == _recordings[1]) {
        await _saveTriggerWord(recorded);
        setState(() {
          _finalWord = recorded;
          _message = "Trigger word saved successfully!";
        });
        _showDialog("Success", "Captured: '$recorded'\nTrigger word saved successfully!");
      } else {
        setState(() => _message = "Words didn't match. Please try again.");
        _recordings.clear();
      }
    } else {
      setState(() => _message = "Now record it again for confirmation.");
    }
  }

  Future<void> _saveTriggerWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trigger_word', word);
  }

  Future<void> _resetTriggerWord() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trigger_word');
    setState(() {
      _finalWord = null;
      _recordings.clear();
      _message = "Press to record your trigger word";
    });
    _showDialog("Reset", "Trigger word has been reset. Please set a new one.");
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF00B050),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(60),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24, top: 60),
            child: const Text(
              'Trigger Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Card with recording button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.circle, size: 10, color: Color(0xFF00B050)),
                        SizedBox(width: 8),
                        Text(
                          'Trigger word',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isListening ? null : _startRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B050),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      label: Text(_isListening ? "Recording..." : "Press to Record"),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _message,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_finalWord != null) ...[
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF00B050)),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: 'Captured successfully,\nYour trigger word is: ',
                style: const TextStyle(
                    color: Colors.black, fontSize: 16, height: 1.5),
                children: [
                  TextSpan(
                    text: _finalWord,
                    style: const TextStyle(color: Color(0xFF00B050)),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetTriggerWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 40),
              ),
              icon: const Icon(Icons.restart_alt),
              label: const Text("Reset Trigger Word"),
            ),
          ],

          const Spacer(),
        ],
      ),
    );
  }
}
