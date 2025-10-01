import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  final String apiUrl = 'http://192.168.0.222:5005/webhooks/rest/webhook';

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    messages.add({'text': text.trim(), 'isUser': true, 'initial': 'YOU'});
    isTyping = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sender': 'user123', 'message': text}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          for (var msg in data) {
            messages.add({'text': msg['text'], 'isUser': false, 'initial': 'BOT'});
          }
        } else {
          messages.add({'text': 'No response from bot.', 'isUser': false, 'initial': 'BOT'});
        }
      } else {
        messages.add({'text': 'Error: ${response.statusCode}', 'isUser': false, 'initial': 'BOT'});
      }
    } catch (e) {
      messages.add({'text': 'Error connecting to server.', 'isUser': false, 'initial': 'BOT'});
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }
}
