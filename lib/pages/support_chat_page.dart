import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('support_messages');
    if (saved != null) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(json.decode(saved));
      });
    }
  }

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('support_messages', json.encode(messages));
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'text': text, 'isUser': true, 'initial': 'YOU'});
      isTyping = true;
    });
    await saveMessages();

    _controller.clear();

    try {
     final response = await http.post(
     Uri.parse('http://192.168.124.104:5005/webhooks/rest/webhook'), 
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'sender': 'user123', 'message': text}),
    );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          for (var msg in data) {
            setState(() {
              messages.add({'text': msg['text'], 'isUser': false, 'initial': 'BOT'});
            });
          }
        } else {
          setState(() {
            messages.add({'text': 'Ask gender-based questions or enquries.', 'isUser': false, 'initial': 'BOT'});
          });
        }
      } else {
        setState(() {
          messages.add({'text': 'Error: ${response.statusCode}', 'isUser': false, 'initial': 'BOT'});
        });
      }
    } catch (e) {
      setState(() {
        messages.add({'text': 'Error connecting to server.', 'isUser': false, 'initial': 'BOT'});
      });
    } finally {
      await saveMessages();
      setState(() {
        isTyping = false;
      });
    }
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    bool isUser = msg['isUser'];
    String initial = msg['initial'];
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser)
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey[300],
            child: Text(initial, style: const TextStyle(color: Colors.black)),
          ),
        if (!isUser) const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 6),
          constraints: const BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: isUser ? Colors.grey[300] : const Color(0xFF00B050),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            msg['text'],
            style: TextStyle(color: isUser ? Colors.black : Colors.white),
          ),
        ),
        if (isUser) const SizedBox(width: 6),
        if (isUser)
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey[300],
            child: Text(initial, style: const TextStyle(color: Colors.black)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: const BoxDecoration(
              color: Color(0xFF00B050),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(60)),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24, top: 60),
            child: const Text(
              'Support Chatbot',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  return buildMessage(messages[index]);
                } else {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey[300],
                        child: const Text('BOT', style: TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        constraints: const BoxConstraints(maxWidth: 250),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B050),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Typing...',
                          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Type here...", border: InputBorder.none),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send, color: Color(0xFF00B050)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
