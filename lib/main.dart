import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'home_screen.dart'; // Make sure this exists and is correct

void main() {
  runApp(const DelulufyApp());
}

class DelulufyApp extends StatelessWidget {
  const DelulufyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.ubuntuMonoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

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
    Future.delayed(const Duration(seconds: 8), () {
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Splash image not found',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.7, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.elasticInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 2, 2, 2).withAlpha(204),
                            blurRadius: 15,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 150,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Logo not found',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    '......Music In Pocket.....credit:-@manasvi',
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    speed: Duration(milliseconds: 140),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
