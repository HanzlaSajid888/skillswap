import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> with WidgetsBindingObserver {
  bool isCameraEnabled = false;
  bool isMicEnabled = false;
  bool isLocationEnabled = false;
  bool isNotificationsEnabled = false;

  String profileVisibility = "PUBLIC";
  String directMessages = "EVERYONE";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
    _fetchPrivacySettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    isCameraEnabled = await Permission.camera.status.isGranted;
    isMicEnabled = await Permission.microphone.status.isGranted;
    isLocationEnabled = await Permission.location.status.isGranted;
    isNotificationsEnabled = await Permission.notification.status.isGranted;
    if (mounted) setState(() {});
  }

  Future<void> _togglePermission(Permission permission, bool currentValue, ValueChanged<bool> onUpdate) async {
    if (!currentValue) {
      final status = await permission.request();
      if (status.isGranted) {
        onUpdate(true);
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      } else {
        onUpdate(false);
      }
    } else {
      _showSettingsDialog();
    }
  }

  Future<void> _fetchPrivacySettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            profileVisibility = data['profileVisibility'] ?? "PUBLIC";
            directMessages = data['directMessages'] ?? "EVERYONE";
          });
        }
      }
    }
  }

  Future<void> _updatePrivacySetting(String field, String value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      if (mounted) {
        setState(() {
          if (field == 'profileVisibility') profileVisibility = value;
          if (field == 'directMessages') directMessages = value;
        });
      }
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({field: value});
      } catch (e) {
        debugPrint("Error updating privacy setting: $e");
      }
    }
  }

  void _showProfileVisibilitySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Profile Visibility", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.public, color: Colors.blue),
                  title: const Text("Public"),
                  subtitle: const Text("Anyone can see your profile and match with you."),
                  trailing: profileVisibility == "PUBLIC" ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    _updatePrivacySetting('profileVisibility', 'PUBLIC');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.red),
                  title: const Text("Private"),
                  subtitle: const Text("Your profile is hidden from new users in the match section."),
                  trailing: profileVisibility == "PRIVATE" ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    _updatePrivacySetting('profileVisibility', 'PRIVATE');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showDirectMessagesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Direct Messages", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.forum, color: Colors.green),
                  title: const Text("Everyone"),
                  subtitle: const Text("Anyone can send you a direct message."),
                  trailing: directMessages == "EVERYONE" ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    _updatePrivacySetting('directMessages', 'EVERYONE');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.purple),
                  title: const Text("Matches Only"),
                  subtitle: const Text("Only people you have matched with can message you."),
                  trailing: directMessages == "MATCHES ONLY" ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    _updatePrivacySetting('directMessages', 'MATCHES ONLY');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("You can manage this permission from the App Settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          )
        ],
      )
    );
  }

  // Design system colors
  final Color backgroundColor = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color subtitleColor = const Color(0xFF64748B);
  final Color boxColor = Colors.white;

  @override
  Widget build(BuildContext context) {
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
          "Privacy & Security",
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
              // Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.shade100.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.tealAccent.shade200.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.shade700,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                           BoxShadow(
                             color: Colors.tealAccent.shade700.withOpacity(0.4),
                             blurRadius: 10,
                             offset: const Offset(0, 4),
                           )
                        ]
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your data is safe",
                            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "End-to-end encryption for all chats and sessions.",
                            style: TextStyle(color: subtitleColor, fontSize: 12),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // SECURITY
              _buildSectionHeader(Icons.lock_outline, "SECURITY", null),
              const SizedBox(height: 10),
              _buildBoxContainer([
                _buildTile(
                  icon: Icons.password, iconColor: Colors.deepPurple, iconBgColor: Colors.deepPurple.shade50,
                  title: "Change Password", subtitle: "Update your login password", 
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && user.email != null) {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Password reset link sent to ${user.email}"),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: ${e.toString()}"),
                              backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Only email users can change passwords."),
                              backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                    }
                  }
                ),
              ]),
              const SizedBox(height: 30),

              // PRIVACY
              _buildSectionHeader(Icons.visibility_outlined, "PRIVACY", Colors.teal.shade500),
              const SizedBox(height: 10),
              _buildBoxContainer([
                _buildTile(
                  icon: Icons.person_outline, iconColor: Colors.teal, iconBgColor: Colors.teal.shade50,
                  title: "Profile Visibility", subtitle: "Control who can see your bio",
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: profileVisibility == "PUBLIC" ? Colors.blue.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(profileVisibility, style: TextStyle(color: profileVisibility == "PUBLIC" ? Colors.blue.shade700 : Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  onTap: _showProfileVisibilitySheet,
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.chat_bubble_outline, iconColor: Colors.teal, iconBgColor: Colors.teal.shade50,
                  title: "Direct Messages", subtitle: "Whom you want to receive texts from",
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(directMessages, style: TextStyle(color: subtitleColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                  onTap: _showDirectMessagesSheet,
                ),
              ]),
              const SizedBox(height: 30),

              // DATA & STORAGE
              _buildSectionHeader(Icons.storage, "DATA & STORAGE", Colors.deepOrange.shade400),
              const SizedBox(height: 10),
              _buildBoxContainer([
                _buildTile(
                  icon: Icons.search, iconColor: Colors.orange, iconBgColor: Colors.orange.shade50,
                  title: "Search History", subtitle: "Clear your recent skill searches",
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text("CLEAR", style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({
                        'searchHistory': FieldValue.delete(),
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Search history cleared successfully!"),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  }
                ),
              ]),
              const SizedBox(height: 30),

              // PERMISSIONS
              _buildSectionHeader(Icons.phone_android, "PERMISSIONS", Colors.purple.shade400),
              const SizedBox(height: 10),
              _buildBoxContainer([
                _buildSwitchTile("Camera", "Required for video sessions", isCameraEnabled, (val) => _togglePermission(Permission.camera, isCameraEnabled, (newVal) => setState(() => isCameraEnabled = newVal))),
                _buildDivider(),
                _buildSwitchTile("Microphone", "Required for audio calls", isMicEnabled, (val) => _togglePermission(Permission.microphone, isMicEnabled, (newVal) => setState(() => isMicEnabled = newVal))),
                _buildDivider(),
                _buildSwitchTile("Location", "Find mentors near you", isLocationEnabled, (val) => _togglePermission(Permission.location, isLocationEnabled, (newVal) => setState(() => isLocationEnabled = newVal))),
                _buildDivider(),
                _buildSwitchTile("Notifications", "Never miss a match", isNotificationsEnabled, (val) => _togglePermission(Permission.notification, isNotificationsEnabled, (newVal) => setState(() => isNotificationsEnabled = newVal))),
              ]),
              
              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Changing some of these settings might affect how your matches\nare generated.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color? customColor) {
    Color color = customColor ?? subtitleColor;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBoxContainer(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildTile({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String subtitle, required Widget trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
      trailing: trailing,
      onTap: onTap ?? () {}, // Clickable effect
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: Colors.tealAccent.shade700,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
