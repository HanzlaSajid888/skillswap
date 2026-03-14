import 'package:flutter/material.dart';
import 'home_screen.dart'; // To navigate back
import 'chat_screen.dart';

class MatchScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background to roughly match the screenshot (purple/blue)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.indigo.shade400], // Adjust these purple/blue shades
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
                
                // IT'S A MATCH! Text
                const Text(
                  "IT'S A MATCH!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Arial', // Fallback, would be nice to have a thick italic font
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 15),
                
                // Subtitle text
                Text(
                  "You and ${matchedUser.name} can help each other\ngrow.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
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
                            Expanded(child: _buildProfileImage(currentUserPhotoUrl)),
                            
                            const SizedBox(width: 40), // Space for heart
                            
                            // Matched User Image
                            Expanded(child: _buildProfileImage(matchedUser.photo)),
                          ],
                        ),
                      ),
                      
                      // Center Heart Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // White Clickable Box (Message button placeholder)
                GestureDetector(
                  onTap: () {
                    // Navigate to messaging
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatUser: matchedUser),
                      ),
                    );
                  },
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),

                // Keep Swiping Button
                TextButton(
                  onPressed: () {
                    // Navigate back to the home screen cards
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Keep Swiping",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  // Helper widget to build the profile images with border
  Widget _buildProfileImage(String url) {
    return Container(
      width: 130,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
