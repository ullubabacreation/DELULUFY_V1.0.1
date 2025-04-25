import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:delulufy_v1/providers/theme_provider.dart';
import 'package:delulufy_v1/utils/shared_prefs.dart';
import 'home_screen.dart';
import 'terms_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool access = await SharedPrefs.getAccessGranted();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: DelulufyApp(accessGranted: access),
    ),
  );
}

class DelulufyApp extends StatelessWidget {
  final bool accessGranted;

  const DelulufyApp({super.key, required this.accessGranted});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        textTheme: GoogleFonts.ubuntuMonoTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        textTheme: GoogleFonts.ubuntuMonoTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: SplashScreen(accessGranted: accessGranted),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool accessGranted;

  const SplashScreen({super.key, required this.accessGranted});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playIntroSound();
    _navigateAfterSplash();
  }

  Future<void> _playIntroSound() async {
    await _audioPlayer.play(AssetSource('sounds/intro.mp3'));
  }

  void _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 8));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              widget.accessGranted ? const HomeScreen() : const TermsScreen(),
        ),
      );
    }
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
                child: Text('Splash image not found',
                    style: TextStyle(color: Colors.red)),
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
                          return const Text('Logo not found',
                              style: TextStyle(color: Colors.red));
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
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TermsScreen()),
                  );
                },
                child: const Text(
                  'View Terms & Conditions',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
