import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;

class SafetyFeaturePage extends StatefulWidget {
  const SafetyFeaturePage({super.key});

  @override
  State<SafetyFeaturePage> createState() => _SafetyFeaturePageState();
}

class _SafetyFeaturePageState extends State<SafetyFeaturePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String? _triggerWord;
  String? _userId; 
  final Telephony telephony = Telephony.instance;
  final String baseUrl = 'http://172.20.10.4:8000/api/contacts';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadTriggerWordAndUser();
  }

  Future<void> _loadTriggerWordAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _triggerWord = prefs.getString('trigger_word');
      _userId = prefs.getString('user_id'); 
    });
  }

  Future<void> _startListening() async {
    if (_triggerWord == null || _triggerWord!.isEmpty) {
      _showDialog("Ooops", "No trigger word set. Please set it first.");
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" && _isListening) {
          _restartListening();
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
        onResult: (result) async {
          String spoken = result.recognizedWords.trim().toLowerCase();
          if (spoken.contains(_triggerWord!.toLowerCase())) {
            _showDialog("SOS Triggered", "Your SOS trigger word was detected!");
            await _sendSOSMessage();
            _stopListening();
          }
        },
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      _showDialog("Speech recognition error", "Speech recognition not available.");
    }
  }

  void _restartListening() {
    if (_isListening) {
      _speech.stop();
      Future.delayed(const Duration(milliseconds: 500), () {
        _speech.listen(
          onResult: (result) async {
            String spoken = result.recognizedWords.trim().toLowerCase();
            if (spoken.contains(_triggerWord!.toLowerCase())) {
              _showDialog("SOS Triggered", "Your SOS trigger word was detected!");
              await _sendSOSMessage();
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

  Future<void> _sendSOSMessage() async {
    try {
      if (_userId == null) {
        debugPrint("User ID not found.");
        return;
      }

      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location services disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final locationUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";

      // 🔹 Fetch contacts from backend
      final response = await http.get(Uri.parse('$baseUrl/$_userId/'));
      if (response.statusCode != 200) {
        debugPrint("Failed to fetch contacts: ${response.body}");
        return;
      }

      final data = jsonDecode(response.body);
      final List contacts = data['contacts'] ?? [];

      if (contacts.isEmpty) {
        debugPrint("No contacts found.");
        return;
      }

     
      final message =
          " SOS! I need help! My location: $locationUrl";

      for (var contact in contacts) {
        String phone = contact['phone'] ?? '';
        if (phone.isNotEmpty) {
          await telephony.sendSms(to: phone, message: message);
          debugPrint("SOS sent to $phone");
        }
      }
    } catch (e) {
      debugPrint("Error sending SOS: $e");
    }
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
