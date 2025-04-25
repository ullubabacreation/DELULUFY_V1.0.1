import 'package:flutter/material.dart';
import 'package:delulufy_v1/utils/shared_prefs.dart';
import 'home_screen.dart';


class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final TextEditingController _keyController = TextEditingController();
  final String validKey = 'DELULUFYPRO_V1'; // 🔐 Replace with your real access key

  String errorText = '';

  void _checkAccessKey() async {
    final enteredKey = _keyController.text.trim();

    if (enteredKey == validKey) {
      await SharedPrefs.saveAccessGranted(true); // ✅ Corrected method name
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        errorText = '❌ Invalid key. Try again!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'By using Delulufy, you agree to respect good vibes, not share your access key, and spread good music only 🎧',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _keyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter Access Key',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorText,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAccessKey,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Unlock Access'),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white12),
            const SizedBox(height: 10),
            const Text(
              '🔒 Delulufy is protected & copyright © 2025',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              'Made with ❤️ by Manasvi',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Contact: kmrmanasvi@gmail.com',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
