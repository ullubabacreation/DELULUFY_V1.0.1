import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'home_screen.dart'; // ✅ Make sure this path is correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playIntroSound();
    _navigateToHome();
  }

  Future<void> _playIntroSound() async {
    await _audioPlayer.play(AssetSource('sounds/intro.mp3'));
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/logo.png',
              height: 120,
            ),
            const SizedBox(height: 50),

            // Typing quote animation
            SizedBox(
              width: 300,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'Courier',
                  color: Colors.white,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      '......Music In Pocket.....credit:-@manasvi',
                      speed: Duration(milliseconds: 70),
                      cursor: '|',
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: Duration(milliseconds: 500),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
