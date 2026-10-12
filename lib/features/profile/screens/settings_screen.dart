// lib/features/profile/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('APP PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.language, color: Colors.blue.shade700, size: 20),
                  ),
                  title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentLang,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(value: 'mr', child: Text('मराठी', style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(value: 'hi', child: Text('हिंदी', style: TextStyle(fontSize: 14))),
                      ],
                      onChanged: (val) {
                        if (val != null) context.read<LanguageProvider>().changeLanguage(val);
                      },
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.notifications_active_outlined, color: Colors.orange.shade700, size: 20),
                  ),
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Switch(
                    value: true,
                    onChanged: (val) {}, // Placeholder
                    activeColor: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}