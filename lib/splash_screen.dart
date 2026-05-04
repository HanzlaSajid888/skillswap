import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
import 'walkthrough/walkthrough_screen.dart';
import 'home_screen.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _loadingController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _logoRotation;
  late Animation<double> _nameFade;
  late Animation<Offset> _nameSlide;
  late Animation<double> _subtitleScale;
  late Animation<double> _subtitleFade;
  late Animation<double> _loadingFade;

  @override
  void initState() {
    super.initState();
    
    // Intro sequence controller
    _introController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 2000),
    );
    
    // Loading dots blink controller
    _loadingController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 1000),
    );

    // 1. Logo scales and fades in with a bounce effect
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // 2. Name fades and slides up smoothly
    _nameSlide = Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    // Subtitle scales up from center smoothly
    _subtitleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic), // Smooth scale from small to big
      ),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    // 3. Loading dots and version fade in at the end
    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _startSequence();
  }

  void _startSequence() async {
    // Stage 1: Play intro sequences (Logo -> Name -> Loading section)
    await _introController.forward();
    
    // Stage 2: Start blinking the loading dots
    _loadingController.repeat();
    
    // Check SharedPreferences while waiting
    final prefs = await SharedPreferences.getInstance();
    final bool seenWalkthrough = prefs.getBool('seenWalkthrough') ?? false;

    // Check Firebase Auth state
    final user = FirebaseAuth.instance.currentUser;

    // Stage 3: Wait for a few seconds simulating a background process
    await Future.delayed(const Duration(seconds: 1));
    
    // Stage 4: Go to the next screen
    if (mounted) {
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FinalPage()),
        );
      } else if (seenWalkthrough) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WalkthroughScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.indigo.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            
            // Logo Animation
            AnimatedBuilder(
              animation: _introController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: RotationTransition(
                      turns: _logoRotation,
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(2), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 140, 
                    height: 140, 
                    fit: BoxFit.cover, 
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Name and Subtitle Animation
            AnimatedBuilder(
              animation: _introController,
              builder: (context, child) {
                return Column(
                  children: [
                    FadeTransition(
                      opacity: _nameFade,
                      child: SlideTransition(
                        position: _nameSlide,
                        child: const Text(
                          "Skillora",
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: ScaleTransition(
                        scale: _subtitleScale,
                        child: const Text(
                          "LEARN • TEACH • GROW",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const Spacer(flex: 3),
            
            // Loading and Version Animation
            AnimatedBuilder(
              animation: _introController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _loadingFade,
                  child: child,
                );
              },
              child: Column(
                children: [
                  // Blinking Loading Dots
                  AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          double opacity = 0.3;
                          double cycleValue = (_loadingController.value + (index * 0.2)) % 1.0;
                          if (cycleValue < 0.5) {
                            opacity = cycleValue * 2.0; 
                          } else {
                            opacity = 1.0 - ((cycleValue - 0.5) * 2.0);
                          }
                          opacity = opacity.clamp(0.3, 1.0);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Opacity(
                              opacity: opacity,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Version Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "VERSION 1.2.4 - MADE WITH ",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 10,
                      ),
                      const Text(
                        " BY HANZLA SAJID",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
