import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = false;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: (val) {},
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification Preferences'),
            subtitle: Text('Manage reminders and alerts'),
          ),
        ],
      ),
    );
  }
}
