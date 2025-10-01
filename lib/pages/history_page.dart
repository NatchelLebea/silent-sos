import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
           width: double.infinity,
            height: 160,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF00B050),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'emergencies sent out',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                HistoryCard(
                  date: '15/06/2025',
                  address: '22 Market Street, ABC building',
                  icon: Icons.videocam,
                  tag: null,
                ),
                const SizedBox(height: 10),
                HistoryCard(
                  date: '15/06/2025',
                  address: '22 Market Street, ABC building',
                  icon: null,
                  tag: 'submitted to SAPS',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String date;
  final String address;
  final IconData? icon;
  final String? tag;

  const HistoryCard({
    super.key,
    required this.date,
    required this.address,
    this.icon,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.group, size: 40),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(address),
                if (tag != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      tag!,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  )
              ],
            ),
          ),
          if (icon != null)
            Icon(icon, color: Colors.green[800]),
        ],
      ),
    );
  }
}
