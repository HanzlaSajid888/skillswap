import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // For LoginScreen
import 'profile_setup_screen.dart'; // For Edit Profile
import 'availability_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';
import 'invite_friends_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF8FAFC);
    final Color textColor = const Color(0xFF1E293B);
    final Color subtitleColor = const Color(0xFF64748B);
    final Color boxColor = Colors.white;

    final String photoUrl = userData?['photo'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80';
    final String name = userData?['name'] ?? 'User';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: boxColor,
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
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Personal Account",
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "PRO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- SKILL COINS BALANCE CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "CURRENT BALANCE",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Icon(Icons.bolt, color: Colors.yellow.shade400, size: 28), // Made bigger
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "${userData?['coins'] ?? 3}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Skill Coins",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Coin Level",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          (userData?['coins'] ?? 3) >= 3 ? "Full" : ((userData?['coins'] ?? 3) > 0 ? "Low" : "Empty"),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (((userData?['coins'] ?? 3) as int).toDouble() / 3.0).clamp(0.0, 1.0) * 0.95, // Leaves a bit of space even at max
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Account Settings Section
              Text(
                "ACCOUNT SETTINGS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: boxColor,
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
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      iconColor: Colors.indigo,
                      iconBgColor: Colors.indigo.shade50,
                      title: "Edit Profile",
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileSetupScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.access_time,
                      iconColor: Colors.blue,
                      iconBgColor: Colors.blue.shade50,
                      title: "My Availability",
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AvailabilityScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.notifications_none,
                      iconColor: Colors.orange,
                      iconBgColor: Colors.orange.shade50,
                      title: "Notifications",
                      textColor: textColor,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      iconColor: Colors.teal,
                      iconBgColor: Colors.teal.shade50,
                      title: "Privacy & Security",
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacySecurityScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // More Section
              Text(
                "MORE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: boxColor,
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
                    _buildSettingsTile(
                      icon: Icons.person_add_alt_1_outlined,
                      iconColor: Colors.purple,
                      iconBgColor: Colors.purple.shade50,
                      title: "Invite Friends",
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InviteFriendsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      iconColor: Colors.blue,
                      iconBgColor: Colors.blue.shade50,
                      title: "Help & Support",
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      iconColor: Colors.grey.shade600,
                      iconBgColor: Colors.grey.shade100,
                      title: "About Skillora",
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Logout Button
              GestureDetector(
                onTap: () async {
                  await _auth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Footer
              Center(
                child: Text(
                  "Skillora v1.2.4 • Made ❤️ by Hanzla Sajid",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 16),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
