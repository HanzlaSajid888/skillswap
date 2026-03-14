import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart';
import 'learning_dashboard_screen.dart';
import 'leaderboard_screen.dart';
import 'messages_screen.dart';
import 'home_screen.dart'; // For FinalPage

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestUser();
  }

  Future<void> _fetchLatestUser() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userData = snapshot.docs.first.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colors based on the screenshot
    final Color backgroundColor = const Color(0xFFF1F5F9); // Light grayish blue background
    final Color textColor = const Color(0xFF1E293B); // Dark slate blue for primary text
    final Color subtitleColor = const Color(0xFF64748B); // Slate gray for secondary text
    final Color primaryColor = Colors.indigo; // Primary blue/indigo

    return Scaffold(
      backgroundColor: backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- TOP WHITE CARD ---
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
                    child: Column(
                      children: [
                        // Custom App Bar Row inside the card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.settings_outlined, color: textColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Profile Image with Star Badge
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.grey.shade200,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userData?['photo'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -5,
                              bottom: -5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: primaryColor,
                                  child: const Icon(Icons.star, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Name
                        Text(
                          userData?['name'] ?? "User",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Bio
                        Text(
                          userData?['bio'] ?? "Learning and teaching.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn("4.8", "RATING", textColor, subtitleColor),
                            Container(width: 1, height: 40, color: Colors.grey.shade300),
                            _buildStatColumn("12", "SESSIONS", textColor, subtitleColor),
                            Container(width: 1, height: 40, color: Colors.grey.shade300),
                            _buildStatColumn("8", "SKILLS", textColor, subtitleColor),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- BODY SECTIONS ---
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Two Action Buttons Row
                        Row(
                          children: [
                            Expanded(child: _buildActionButton(Icons.bar_chart, "My Progress", Colors.indigo.shade100, Colors.indigo, textColor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LearningDashboardScreen(),
                                  ),
                                );
                              }
                            )),
                            const SizedBox(width: 15),
                            Expanded(child: _buildActionButton(Icons.emoji_events_outlined, "Leaderboard", Colors.orange.shade100, Colors.orange.shade700, textColor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LeaderboardScreen(),
                                  ),
                                );
                              }
                            )),
                          ],
                        ),
                        const SizedBox(height: 35),

                        // Skills I Teach Header
                        Text(
                          "SKILLS I TEACH",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: subtitleColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        // Skills Tags/Chips
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _buildSkillsList(userData?['teachSkills'] as List<dynamic>?),
                        ),

                        const SizedBox(height: 35),

                        // Recent Reviews Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "RECENT REVIEWS",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: subtitleColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              "View All >",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Review Card
                        _buildReviewCard(textColor, subtitleColor),

                        const SizedBox(height: 80), // extra padding for scrolling
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.grey.shade400, size: 28),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: UserSearchDelegate(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.indigo, size: 28),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for Stats Column
  Widget _buildStatColumn(String value, String label, Color valueColor, Color labelColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900, // Black/ExtraBold
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  // Helper widget for Progress/Leaderboard buttons
  Widget _buildActionButton(IconData icon, String label, Color iconBgColor, Color iconColor, Color textColor, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generate skills chips
  List<Widget> _buildSkillsList(List<dynamic>? skills) {
    List<String> displaySkills = skills?.map((e) => e.toString()).toList() ?? ["React", "UI Design"];
    
    return displaySkills.map((skill) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          skill,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.indigo.shade900,
          ),
        ),
      );
    }).toList();
  }

  // Builder for the Review Card
  Widget _buildReviewCard(Color textColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Sarah Chen",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '"Alex is an amazing teacher! He explained React hooks so clearly."',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: subtitleColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
