import 'package:flutter/material.dart';
import 'home_screen.dart'; // To navigate back
import 'chat_screen.dart';
import 'models/user_profile.dart';

class MatchScreen extends StatefulWidget {
  final UserProfile matchedUser;
  // In a real app, you'd also pass the current user's profile to display their photo,
  // but for this UI, we will use a dummy/hardcoded current user photo if needed,
  // or pass it through if available.
  final String currentUserPhotoUrl;

  const MatchScreen({
    super.key,
    required this.matchedUser,
    required this.currentUserPhotoUrl,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _heartbeatController;
  
  late Animation<double> _textScale;
  late Animation<Offset> _leftImageSlide;
  late Animation<Offset> _rightImageSlide;
  late Animation<double> _heartScale;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    _leftImageSlide = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    _rightImageSlide = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _heartScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartbeatController, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      _heartbeatController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background to roughly match the screenshot (purple/blue)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.indigo.shade400], // Deeper colors for premium look
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // IT'S A MATCH! Text animated scale
                ScaleTransition(
                  scale: _textScale,
                  child: const Text(
                    "IT'S A MATCH!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Arial', // Fallback, would be nice to have a thick italic font
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Subtitle text faded in
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    "Start chatting to exchange your skills",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),

                // Pictures Row
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Current User Image
                            Expanded(
                              child: SlideTransition(
                                position: _leftImageSlide,
                                child: _buildProfileImage(widget.currentUserPhotoUrl, -10 * 3.14159 / 180),
                              ),
                            ),
                            
                            const SizedBox(width: 40), // Space for heart
                            
                            // Matched User Image
                            Expanded(
                              child: SlideTransition(
                                position: _rightImageSlide,
                                child: _buildProfileImage(widget.matchedUser.photo, 10 * 3.14159 / 180),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Center Heart Icon animated heartbeat
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _heartScale,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.pinkAccent,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Send Message Button faded in
                FadeTransition(
                  opacity: _fadeAnim,
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to messaging
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(chatUser: widget.matchedUser),
                        ),
                      );
                    },
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Keep Swiping Button faded in
                FadeTransition(
                  opacity: _fadeAnim,
                  child: TextButton(
                    onPressed: () {
                      // Navigate back to the home screen cards
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Keep Swiping",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build the profile images with border and optional rotation
  Widget _buildProfileImage(String url, double rotationAngle) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        width: 130,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
