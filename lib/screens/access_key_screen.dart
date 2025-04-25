import 'dart:math';
import 'package:flutter/material.dart';

// Make sure this is added in pubspec.yaml:
// shared_preferences: ^2.2.2
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';


import '../utils/shared_prefs.dart';       // Your helper for key handling
import '../home_screen.dart';
      // Home screen after key is accepted

class AccessKeyScreen extends StatefulWidget {
  const AccessKeyScreen({super.key});

  @override
  State<AccessKeyScreen> createState() => _AccessKeyScreenState();
}

class _AccessKeyScreenState extends State<AccessKeyScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _termsAccepted = false;
  String _generatedKey = '';
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _generateAccessKey();
  }

  void _generateAccessKey() {
    const chars = 'ABCDEFGH12345678XYZ';
    final rand = Random();
    String key = List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
    _generatedKey = key;
    SharedPrefs.saveGeneratedKey(key); // Saves to shared_preferences
  }

  void _validateKey() async {
    final enteredKey = _keyController.text.trim();
    final savedKey = await SharedPrefs.getGeneratedKey();

    if (!_termsAccepted) {
      setState(() => _errorText = 'Please accept the terms.');
    } else if (enteredKey != savedKey) {
      setState(() => _errorText = 'Invalid key. Try again.');
    } else {
      await SharedPrefs.saveAccessGranted(true);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontFamily: 'UbuntuMono',
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'By using Delulufy, you agree to the rules of non-commercial use, and limited access only.',
              style: TextStyle(
                fontFamily: 'UbuntuMono',
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                      _errorText = '';
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'I accept the terms',
                    style: TextStyle(color: Colors.white, fontFamily: 'UbuntuMono'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              style: const TextStyle(color: Colors.white, fontFamily: 'UbuntuMono'),
              decoration: InputDecoration(
                hintText: 'Enter access key',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _validateKey,
              child: const Text('Continue'),
            ),
            if (_errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorText,
                  style: const TextStyle(color: Colors.redAccent, fontFamily: 'UbuntuMono'),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Generated Key: $_generatedKey',
              style: const TextStyle(
                fontFamily: 'UbuntuMono',
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
