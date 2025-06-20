import 'package:flutter/material.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool emailNotifications = true;
  bool pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Email Notifications'),
            value: emailNotifications,
            onChanged: (bool value) {
              setState(() {
                emailNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: pushNotifications,
            onChanged: (bool value) {
              setState(() {
                pushNotifications = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferences saved')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save Preferences'),
          ),
        ],
      ),
    );
  }
}