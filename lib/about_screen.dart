import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_security_screen.dart';
import 'invite_friends_screen.dart';
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Design system colors
    final Color backgroundColor = const Color(0xFFF8FAFC);
    final Color textColor = const Color(0xFF1E293B);
    final Color subtitleColor = const Color(0xFF64748B);
    final Color boxColor = Colors.white;

    Widget buildSectionHeader(IconData icon, String title, Color? customColor) {
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

    Widget buildBoxContainer(List<Widget> children) {
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

    Widget buildTile({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String subtitle, required Widget trailing, VoidCallback? onTap}) {
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
        onTap: onTap ?? () {},
      );
    }

    Widget buildDivider() {
      return Container(
        height: 1,
        color: Colors.grey.shade100,
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );
    }

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
          "About Skillora",
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
              // Logo Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade500,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.shade500.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ]
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Skillora",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "LEARN. TEACH. GROW.",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // APP INFO
              buildSectionHeader(Icons.info_outline, "APP INFO", Colors.indigo.shade400),
              const SizedBox(height: 10),
              buildBoxContainer([
                buildTile(
                  icon: Icons.menu_book_outlined, iconColor: Colors.indigo, iconBgColor: Colors.indigo.shade50,
                  title: "What is Skillora?", subtitle: "Learn about our mission and community", 
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: [
                            Icon(Icons.bolt, color: Colors.indigo.shade500),
                            const SizedBox(width: 8),
                            const Text("What is Skillora?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        content: const Text(
                          "Skillora is a modern skill-sharing platform that connects learners and individuals who want to grow together. It is built on a simple idea: exchange skills instead of money. Whether you want to learn a new skill or share your expertise, Skillora helps you find the right match. With smart matching, real-time chat, video calling, and easy session scheduling, Skillora creates a collaborative space where users can teach, learn, and grow together. Our goal is to make knowledge accessible, practical, and driven by community.",
                          style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF1E293B)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    );
                  },
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.widgets_outlined, iconColor: Colors.blue, iconBgColor: Colors.blue.shade50,
                  title: "App Version", subtitle: "1.2.4 (Official Build)", 
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text("LATEST", style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
              const SizedBox(height: 30),

              // DEVELOPER
              buildSectionHeader(Icons.person_outline, "DEVELOPER", Colors.purple.shade400),
              const SizedBox(height: 10),
              buildBoxContainer([
                buildTile(
                  icon: Icons.bolt, iconColor: Colors.deepPurple, iconBgColor: Colors.deepPurple.shade50,
                  title: "Developer", subtitle: "Hanzla Sajid",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.email_outlined, iconColor: Colors.purple, iconBgColor: Colors.purple.shade50,
                  title: "Contact Email", subtitle: "ranahunzlaa.huni777@gmail.com",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'ranahunzlaa.huni777@gmail.com',
                    );
                    await launchUrl(emailLaunchUri);
                  },
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.code, iconColor: Colors.purple, iconBgColor: Colors.purple.shade50,
                  title: "GitHub Portfolio", subtitle: "github.com/HunzlaSajid",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    final Uri url = Uri.parse('https://github.com/HunzlaSajid');
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
              ]),
              const SizedBox(height: 30),

              // CONNECT
              buildSectionHeader(Icons.share_outlined, "CONNECT", Colors.redAccent.shade400),
              const SizedBox(height: 10),
              buildBoxContainer([
                buildTile(
                  icon: Icons.camera_alt_outlined, iconColor: Colors.pink, iconBgColor: Colors.pink.shade50,
                  title: "Instagram Profile", subtitle: "Follow for updates",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    final Uri url = Uri.parse('https://www.instagram.com/hunzla__khan/');
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.work_outline, iconColor: Colors.blue.shade700, iconBgColor: Colors.blue.shade50,
                  title: "Connect on LinkedIn", subtitle: "For professional networking",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    final Uri url = Uri.parse('https://www.linkedin.com/in/hanzla-sajid-03a686365/');
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.share_outlined, iconColor: Colors.teal, iconBgColor: Colors.teal.shade50,
                  title: "Share App", subtitle: "Invite others to learn",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InviteFriendsScreen(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 30),

              // LEGAL
              buildSectionHeader(Icons.gavel_outlined, "LEGAL", Colors.blueGrey.shade400),
              const SizedBox(height: 10),
              buildBoxContainer([
                buildTile(
                  icon: Icons.description_outlined, iconColor: Colors.blueGrey, iconBgColor: Colors.blueGrey.shade50,
                  title: "Terms & Conditions", subtitle: "Rules of the platform",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: [
                            Icon(Icons.gavel_outlined, color: Colors.blueGrey),
                            const SizedBox(width: 8),
                            const Text("Terms & Conditions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text("1. Respect & Professional Behavior", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text("Users must treat each other with respect. Harassment, hate speech, abusive language, or inappropriate behavior during chats or video calls is strictly prohibited.", style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1E293B))),
                              SizedBox(height: 12),
                              Text("2. No Monetary Transactions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text("Skillora is built on a skill-for-skill exchange model. Demanding money or financial compensation in exchange for teaching a skill is not allowed.", style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1E293B))),
                              SizedBox(height: 12),
                              Text("3. Authentic Profiles & Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text("You must provide accurate information about your identity and your skills. Misrepresenting your expertise will result in account termination.", style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1E293B))),
                              SizedBox(height: 12),
                              Text("4. Privacy & Content Safety", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text("Do not share sensitive personal information. Furthermore, sharing explicit, copyrighted, or illegal content in messages or calls is strictly forbidden.", style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1E293B))),
                              SizedBox(height: 12),
                              Text("5. Age Restriction", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text("You must be at least 13 years of age to use Skillora. If you are under 18, you must have the consent of a parent or guardian.", style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1E293B))),
                              SizedBox(height: 12),
                              Text("6. Account Suspension", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text("Skillora reserves the right to suspend, ban, or delete any account that violates these Terms and Conditions without prior notice.", style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1E293B))),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Agree & Close", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    );
                  },
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.shield_outlined, iconColor: Colors.blueGrey, iconBgColor: Colors.blueGrey.shade50,
                  title: "Privacy & Security", subtitle: "How we protect your data",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacySecurityScreen(),
                      ),
                    );
                  },
                ),
              ]),
              
              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Made ❤️ by Hanzla sajid",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
