import 'package:flutter/material.dart';
import 'learning_dashboard_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedTab = "WEEKLY";

  @override
  Widget build(BuildContext context) {
    // Reference colors
    final Color backgroundColor = const Color(0xFFF8FAFC);
    final Color textColor = const Color(0xFF1E293B);
    final Color subtitleColor = const Color(0xFF64748B);
    final Color primaryThemeColor = Colors.indigo;
    final Color secondaryThemeColor = Colors.indigo.shade400;
    
    // Mentor mock data
    final List<Map<String, dynamic>> weeklyMentors = [
      {
        "rank": 1,
        "name": "Elena Gilbert",
        "expertise": "Master Guitarist",
        "rating": "5.0",
        "photo": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150&q=80",
      },
      {
        "rank": 2,
        "name": "Sarah Chen",
        "expertise": "UI/UX Specialist",
        "rating": "4.9",
        "photo": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
      },
      {
        "rank": 3,
        "name": "Alex Rivera",
        "expertise": "Frontend Expert",
        "rating": "4.8",
        "photo": "https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=150&q=80",
      },
    ];

    final List<Map<String, dynamic>> allTimeMentors = [
      {
        "rank": 1,
        "name": "David Smith",
        "expertise": "Senior Developer",
        "rating": "5.0",
        "photo": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80",
      },
      {
        "rank": 2,
        "name": "Emma Watson",
        "expertise": "Data Scientist",
        "rating": "4.9",
        "photo": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80",
      },
      {
        "rank": 3,
        "name": "Michael Lee",
        "expertise": "Cloud Architect",
        "rating": "4.9",
        "photo": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80",
      },
    ];

    final displayedMentors = selectedTab == "WEEKLY" ? weeklyMentors : allTimeMentors;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top Purple Podium Area
                Container(
                  padding: const EdgeInsets.only(top: 20, bottom: 40), // More bottom padding for visual curve
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryThemeColor, secondaryThemeColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Custom AppBar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                               decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                               ),
                               child: IconButton(
                                 icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                                 onPressed: () => Navigator.pop(context),
                               ),
                            ),
                            const Text(
                              "Leaderboard",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 48), // Empty space where the graph icon would be
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Podium
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 2nd Place
                          _buildPodiumAvatar(
                             displayedMentors[1]['photo'],
                             displayedMentors[1]['name'],
                             2,
                             60,
                             Colors.grey.shade300,
                          ),
                          const SizedBox(width: 15),
                          
                          // 1st Place
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: _buildPodiumAvatar(
                               displayedMentors[0]['photo'],
                               displayedMentors[0]['name'],
                               1,
                               80,
                               Colors.amber,
                               hasCrown: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          
                          // 3rd Place
                          _buildPodiumAvatar(
                             displayedMentors[2]['photo'],
                             displayedMentors[2]['name'],
                             3,
                             60,
                             Colors.orange.shade300, // Bronze
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Top Mentors List Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Header Row (Top Mentors / Toggle)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "TOP MENTORS",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: subtitleColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => selectedTab = "WEEKLY"),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: selectedTab == "WEEKLY" ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: selectedTab == "WEEKLY" ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 4,
                                            )
                                          ] : null,
                                        ),
                                        child: Text(
                                          "WEEKLY",
                                          style: TextStyle(
                                            fontSize: 10, 
                                            fontWeight: FontWeight.bold, 
                                            color: selectedTab == "WEEKLY" ? Colors.indigo : subtitleColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => selectedTab = "ALL TIME"),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: selectedTab == "ALL TIME" ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: selectedTab == "ALL TIME" ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 4,
                                            )
                                          ] : null,
                                        ),
                                        child: Text(
                                          "ALL TIME",
                                          style: TextStyle(
                                            fontSize: 10, 
                                            fontWeight: FontWeight.bold, 
                                            color: selectedTab == "ALL TIME" ? Colors.indigo : subtitleColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // List of Mentors
                          ...displayedMentors.map((mentor) => _buildMentorCard(mentor, textColor, subtitleColor)).toList(),
                          
                          const SizedBox(height: 100), // Padding for sticky banner
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Sticky Bottom Banner "Your Ranking"
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryThemeColor, secondaryThemeColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryThemeColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      "#42",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80"), // Dummy current user photo
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Your Ranking",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Top 15% of mentors this month",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearningDashboardScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "View Stats",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryThemeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumAvatar(String photoUrl, String name, int rank, double size, Color ringColor, {bool hasCrown = false}) {
    // Truncate name for display on podium
    List<String> nameParts = name.split(" ");
    String displayName = nameParts.length > 1 ? "${nameParts[0]} ${nameParts[1][0]}." : nameParts[0];

    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.only(top: hasCrown ? 15.0 : 0),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ringColor, width: 3),
                      image: DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ringColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.indigo, width: 2), // Match podium bg
                    ),
                    child: Text(
                      rank.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Optional crown for 1st place
            if (hasCrown) ...[
              const Positioned(
                top: 0,
                child: Icon(Icons.change_history, color: Colors.amber, size: 16), // A triangular shape representing a crown
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor, Color textColor, Color subtitleColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
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
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              "#${mentor['rank']}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(mentor['photo']),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentor['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  mentor['expertise'],
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  mentor['rating'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
