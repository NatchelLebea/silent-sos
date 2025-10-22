import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

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
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        relationship: json['relationship'] ?? '',
      );
}

class ContactsPage extends StatefulWidget {
  final String userId;

  const ContactsPage({super.key, required this.userId});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<Contact> _contacts = [];
  bool isLoading = false;

  final String baseUrl = 'http://172.20.10.4:8000/api/contacts';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchContacts();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isRestricted) {
      var result = await Permission.location.request();
      if (result.isPermanentlyDenied) await openAppSettings();
    }
  }

  Future<void> _fetchContacts() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/${widget.userId}/'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> list = data['contacts'] ?? [];
        setState(() {
          _contacts.clear();
          _contacts.addAll(list.map((e) => Contact.fromJson(e)).toList());
        });
      } else {
        debugPrint('Failed to load contacts: ${res.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addOrUpdateContact({Contact? existing, int? index}) async {
    final _formKey = GlobalKey<FormState>();
    String name = existing?.name ?? '';
    String phone = existing?.phone ?? '';
    String relationship = existing?.relationship ?? 'Mother';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add New Contact' : 'Update Contact'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter a name' : null,
                      onSaved: (value) => name = value!.trim(),
                    ),
                    TextFormField(
                      initialValue: phone,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter a phone number';
                        final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
                        if (!phoneRegex.hasMatch(value)) return 'Invalid phone number';
                        return null;
                      },
                      onSaved: (value) => phone = value!.trim(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Relationship'),
                      value: relationship,
                      items: const [
                        DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                        DropdownMenuItem(value: 'Father', child: Text('Father')),
                        DropdownMenuItem(value: 'Sister', child: Text('Sister')),
                        DropdownMenuItem(value: 'Brother', child: Text('Brother')),
                        DropdownMenuItem(value: 'Friend', child: Text('Friend')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        if (value != null) dialogSetState(() => relationship = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final contact = Contact(name: name, phone: phone, relationship: relationship);
                    if (existing == null) {
                      await _addContact(contact);
                    } else {
                      await _updateContact(index!, contact);
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Text(existing == null ? 'Add Contact' : 'Update Contact'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _addContact(Contact contact) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/${widget.userId}/add/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(contact.toJson()),
      );
      if (res.statusCode == 201) _fetchContacts();
    } catch (e) {
      debugPrint('Error adding contact: $e');
    }
  }

  Future<void> _updateContact(int index, Contact contact) async {
    try {
      final updatedContacts = _contacts.map((c) => c.toJson()).toList();
      updatedContacts[index] = contact.toJson();
      final res = await http.put(
        Uri.parse('$baseUrl/${widget.userId}/update/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contacts': updatedContacts}),
      );
      if (res.statusCode == 200) _fetchContacts();
    } catch (e) {
      debugPrint('Error updating contact: $e');
    }
  }

  Future<void> _deleteContact(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final res = await http.delete(Uri.parse('$baseUrl/${widget.userId}/delete/$index/'));
        if (res.statusCode == 200) _fetchContacts();
      } catch (e) {
        debugPrint('Error deleting contact: $e');
      }
    }
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
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(60)),
            ),
            padding: const EdgeInsets.only(left: 24, top: 60, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contacts',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _addOrUpdateContact(),
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text('New Contact', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                    ? const Center(child: Text('No contacts added yet.', style: TextStyle(color: Colors.black54, fontSize: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: contact.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                          children: [
                                            TextSpan(
                                              text: ' — ${contact.relationship}',
                                              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey.shade600, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(contact.phone),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _addOrUpdateContact(existing: contact, index: index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteContact(index),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
