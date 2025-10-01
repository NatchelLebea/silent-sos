import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contact {
  final String name;
  final String phone;
  final String relationship;

  Contact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        name: json['name'],
        phone: json['phone'],
        relationship: json['relationship'],
      );
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
    _loadContacts();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isRestricted) {
      var result = await Permission.location.request();
      if (result.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedContacts = prefs.getStringList('contacts') ?? [];
    setState(() {
      _contacts.clear();
      _contacts.addAll(savedContacts.map((e) => Contact.fromJson(json.decode(e))));
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactList = _contacts.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList('contacts', contactList);
  }

  Future<void> _showAddContactDialog() async {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String phone = '';
    String relationship = 'Mother';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AlertDialog(
            title: const Text('Add New Contact'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
                      onSaved: (value) => name = value!.trim(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter a phone number' : null,
                      onSaved: (value) => phone = value!.trim(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Relationship'),
                      value: relationship,
                      items: const [
                        DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                        DropdownMenuItem(value: 'Sister', child: Text('Sister')),
                        DropdownMenuItem(value: 'Friend', child: Text('Friend')),
                        DropdownMenuItem(value: 'Brother', child: Text('Brother')),
                        DropdownMenuItem(value: 'Father', child: Text('Father')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          dialogSetState(() {
                            relationship = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      _contacts.insert(
                        0,
                        Contact(
                          name: name,
                          phone: phone,
                          relationship: relationship,
                        ),
                      );
                    });
                    _saveContacts();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add Contact'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFF00B050),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(60),
              ),
            ),
            padding: const EdgeInsets.only(left: 24, top: 60, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contacts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showAddContactDialog,
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'New Contact',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _contacts.isEmpty
                ? const Center(
                    child: Text(
                      'No contacts added yet.',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contacts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _contacts.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Center(
                            child: Text(
                              'An SOS will be sent to the listed people',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        );
                      }
                      final contact = _contacts[index];
                      return Column(
                        children: [
                          ContactCard(
                            name: contact.name,
                            phone: contact.phone,
                            relationship: contact.relationship,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final String name;
  final String phone;
  final String relationship;

  const ContactCard({
    super.key,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade400,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: ' — $relationship',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(phone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
