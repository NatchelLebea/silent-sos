import 'package:flutter/material.dart';
import 'contacts_page.dart';
import 'history_page.dart';
import 'trigger_settings_page.dart';
import 'support_chat_page.dart';
import 'safety_feature_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    ContactsPage(),
    HistoryPage(),
    TriggerSettingsPage(),
    SupportChatPage(),
    SafetyFeaturePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: Color(0xFF0EAD69),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Trigger'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Safety'),
        ],
      ),
    );
  }
}
