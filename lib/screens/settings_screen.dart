import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isKeyValid = false;

  @override
  void initState() {
    super.initState();
    _checkKeyStatus();
  }

  Future<void> _checkKeyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('user_key');
    setState(() {
      _isKeyValid = key != null && key.isNotEmpty;
    });
  }

  Future<void> _clearPlaylists() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Do you really want to clear all playlists?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Clear")),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('liked_songs'); // or change to 'playlists' if you save under another key
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All playlists cleared")),
      );
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Delulufy',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Manasvi',
      children: const [
        SizedBox(height: 10),
        Text('Delulufy is a lightweight music made with ❤️for all friends .'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Key Status"),
            subtitle: Text(_isKeyValid ? "✅ Key is valid (user verified)" : "❌ Key is not set or invalid"),
            leading: const Icon(Icons.vpn_key),
          ),
          ListTile(
            title: const Text("Clear All Playlists"),
            leading: const Icon(Icons.delete),
            onTap: _clearPlaylists,
          ),
          ListTile(
            title: const Text("About App"),
            leading: const Icon(Icons.info_outline),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }
}
