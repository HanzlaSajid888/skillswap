import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _page1Controller;
  late Animation<double> _blueCardFadeAnim;
  late Animation<double> _pinkCardSlideAnim;

  late AnimationController _heartAnimController;
  late Animation<double> _heartSlideAnim;

  late AnimationController _puzzleAnimController;
  late Animation<double> _puzzleSlideAnim;

  late Animation<double> _textFadeSlideAnim;

  late AnimationController _page2Controller;
  late Animation<double> _page2MessageScaleAnim;

  late AnimationController _page3Controller;
  late Animation<double> _page3TextAnim;

  late AnimationController _coinAnimController;
  late Animation<double> _coinRotateAnim;
  late AnimationController _starsAnimController;

  @override
  void initState() {
    super.initState();
    _page1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _blueCardFadeAnim = CurvedAnimation(
      parent: _page1Controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );
    _pinkCardSlideAnim = CurvedAnimation(
      parent: _page1Controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    );

    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heartSlideAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _heartAnimController,
        curve: Curves.easeInOutSine,
      ),
    );
    _heartAnimController.repeat(reverse: true);

    _puzzleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Slower animation speed
    );
    _puzzleSlideAnim = Tween<double>(begin: -8.0, end: 8.0).animate( // Very subtle bounce to preserve gaps
      CurvedAnimation(
        parent: _puzzleAnimController,
        curve: Curves.easeInOutSine,
      ),
    );
    _puzzleAnimController.repeat(reverse: true);

    _textFadeSlideAnim = CurvedAnimation(
      parent: _page1Controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );

    _page2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Adjusted speed for single pop
    );
    _page2MessageScaleAnim = CurvedAnimation(
      parent: _page2Controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack), // Changed from elasticOut to stop shaking
    );

    _page3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _page3TextAnim = CurvedAnimation(
      parent: _page3Controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );

    _coinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _coinRotateAnim = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(
        parent: _coinAnimController,
        curve: Curves.easeInOutSine, // Smooth pendulum rotation
      ),
    );
    _coinAnimController.repeat(reverse: true);

    _starsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _starsAnimController.repeat(); // Continuous loop, matching half-cycle of the coin

    // Thora delay de kar run karte hain takay page open hone ke baad chalay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _page1Controller.forward(from: 0.0);
      });
    });
  }

  @override
  void dispose() {
    _coinAnimController.dispose();
    _starsAnimController.dispose();
    _page3Controller.dispose();
    _page2Controller.dispose();
    _puzzleAnimController.dispose();
    _heartAnimController.dispose();
    _page1Controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('seenWalkthrough', true);
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: Text(
              'SKIP',
              style: TextStyle(
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                  if (page == 0) {
                    _page1Controller.forward(from: 0.0);
                  } else if (page == 1) {
                    _page2Controller.forward(from: 0.0);
                  } else if (page == 2) {
                    _page3Controller.forward(from: 0.0);
                  }
                },
                children: [
                  _buildFirstPage(),
                  _buildSecondPage(),
                  _buildThirdPage(),
                ],
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Illustration Placeholder (Cards with Heart)
          _buildCardsIllustration(),
          const Spacer(flex: 2),
          AnimatedBuilder(
            animation: _textFadeSlideAnim,
            builder: (context, child) {
              return Opacity(
                opacity: _textFadeSlideAnim.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - _textFadeSlideAnim.value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                // Title
                const Text(
                  'Swipe for Mentors',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B), // Dark blue/gray
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                const Text(
                  'Find the perfect match for the skills you want\nto learn. Swipe right to connect, chat, and\nstart your journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildSecondPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          _buildTeachLearnIllustration(),
          const Spacer(flex: 2),
          const Text(
            'Teach & Learn',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B), // Dark blue/gray
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          const Text(
            'Share your expertise and learn from others.\nNo money involved—just pure knowledge\nexchange.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildThirdPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          _buildCoinIllustration(),
          const Spacer(flex: 2),
          const Text(
            'Earn Skill Coins',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B), // Dark blue/gray
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          const Text(
            'Teach a skill to earn coins. Spend them to\nrequest direct 1-on-1 sessions from top-tier\nmentors. Grow your career today!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildCoinIllustration() {
    return SizedBox(
      height: 280,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withOpacity(0.05), // much lighter glow
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1), // reduced opacity
                  blurRadius: 25, // less blur
                  spreadRadius: 2, // less spread
                )
              ]
            ),
          ),
          // Main Coin (Animated Rotation)
          AnimatedBuilder(
            animation: _coinRotateAnim,
            builder: (context, child) {
              return Transform.rotate(
                angle: _coinRotateAnim.value,
                child: child,
              );
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD54F), // Light Amber
                    Color(0xFFFF8F00), // Dark Orange
                  ],
                ),
                boxShadow: [
                   BoxShadow(
                     color: Colors.orange.shade800.withOpacity(0.4),
                     blurRadius: 15,
                     offset: const Offset(0, 8),
                   )
                ]
              ),
              child: const Icon(
                Icons.bolt,
                size: 80,
                color: Color(0xFF5D4037), // Dark brown lightning
              ),
            ),
          ),
          // Dynamic Erupting Stars synchronized with swings
          AnimatedBuilder(
            animation: _starsAnimController,
            builder: (context, child) {
              final t = _starsAnimController.value;
              double opacity = 1.0;
              if (t < 0.2) opacity = t / 0.2;
              else if (t > 0.8) opacity = (1.0 - t) / 0.2;

              // Stars expanding outwards and upwards from center (140, 140)
              final s1Left = 140.0 - (90.0 * t);
              final s1Top = 140.0 - (100.0 * t);
              
              final s2Left = 140.0;
              final s2Top = 140.0 - (130.0 * t);
              
              final s3Left = 140.0 + (90.0 * t);
              final s3Top = 140.0 - (100.0 * t);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: s1Top,
                    left: s1Left - 12,
                    child: Opacity(
                      opacity: opacity,
                      child: Icon(Icons.star, color: Colors.amber.shade300, size: 24),
                    ),
                  ),
                  Positioned(
                    top: s2Top,
                    left: s2Left - 10,
                    child: Opacity(
                      opacity: opacity,
                      child: Icon(Icons.star, color: Colors.amber.shade200, size: 20),
                    ),
                  ),
                  Positioned(
                    top: s3Top,
                    left: s3Left - 8,
                    child: Opacity(
                      opacity: opacity,
                      child: Icon(Icons.star, color: Colors.amber.shade400, size: 16),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeachLearnIllustration() {
    return SizedBox(
      height: 280,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center Big Container
          AnimatedBuilder(
            animation: _puzzleSlideAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _puzzleSlideAnim.value),
                child: child,
              );
            },
            child: Container(
              width: 140, // Smaller to give space
              height: 140,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Icon(
                Icons.extension_outlined,
                size: 60,
                color: Colors.indigo.shade600,
              ),
            ),
          ),
          // Top Right Video Icon
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFA569BD),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA569BD).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: const Icon(
                Icons.videocam,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          // Bottom Left Chat Icon
          Positioned(
            bottom: 20,
            left: 20,
            child: AnimatedBuilder(
              animation: _page2MessageScaleAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: _page2MessageScaleAnim.value,
                  child: child,
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade600,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.shade600.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsIllustration() {
    // A pure Flutter graphical representation similar to the picture
    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bottom Card (Blueish)
          AnimatedBuilder(
            animation: _blueCardFadeAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * _blueCardFadeAnim.value),
                child: Opacity(
                  opacity: _blueCardFadeAnim.value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Transform.translate(
              offset: const Offset(-20, 10),
              child: Transform.rotate(
                angle: -0.2, // Tilted left
                child: Container(
                  width: 130,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600, // Matching splash screen indigo
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade600.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(-5, 5),
                      )
                    ]
                  ),
                ),
              ),
            ),
          ),
          // Top Card (Purple/Pinkish)
          AnimatedBuilder(
            animation: _pinkCardSlideAnim,
            builder: (context, child) {
              final dx = 200 - (190 * _pinkCardSlideAnim.value);
              return Transform.translate(
                offset: Offset(dx, -5),
                child: Opacity(
                  opacity: _pinkCardSlideAnim.value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Transform.rotate(
              angle: 0.1, // Tilted slightly right
              child: Container(
                width: 140,
                height: 180,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFA569BD), // Softer, dull pink/purple
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA569BD).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(5, 10),
                    )
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedBuilder(
                      animation: _heartSlideAnim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_heartSlideAnim.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Color(0xFFA569BD),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 8,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return AnimatedBuilder(
      animation: _textFadeSlideAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeSlideAnim.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textFadeSlideAnim.value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 32.0),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => _buildDot(index)),
          ),
          const SizedBox(height: 32),
          // Next Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (_currentPage < 2) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                } else {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seenWalkthrough', true);
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600, // Splash screen color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentPage == 2 ? 'Get Started' : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Login Link (Visible only on the last page)
          AnimatedOpacity(
            opacity: _currentPage == 2 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                GestureDetector(
                  onTap: () async {
                    if (_currentPage == 2) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('seenWalkthrough', true);
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo.shade600 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
