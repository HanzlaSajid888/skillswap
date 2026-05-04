import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  final String inviteLink = "https://skillora.app/invite/user123";
  final String inviteMessage = "Join me on Skillora! Let's swap skills and grow together! https://skillora.app/invite/user123";

  void _shareViaWhatsApp() async {
    final Uri url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(inviteMessage)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Share.share(inviteMessage);
    }
  }

  void _shareViaSMS() async {
    final Uri url = Uri.parse('sms:?body=${Uri.encodeComponent(inviteMessage)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Share.share(inviteMessage);
    }
  }

  void _shareViaMessenger() async {
    // Attempt to open messenger specific intent, fallback to share sheet if not installed
    final Uri url = Uri.parse('fb-messenger://share/?link=${Uri.encodeComponent(inviteLink)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Share.share(inviteMessage);
    }
  }

  void _shareMore() {
    Share.share(inviteMessage);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF8FAFC);
    final Color textColor = const Color(0xFF1E293B);
    final Color subtitleColor = const Color(0xFF64748B);

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
          "Invite Friends",
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Removed Header Texts and Purple Banner


              // YOUR REFERRAL LINK
              Text(
                "YOUR REFERRAL LINK",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade400,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "https://skillora.app/invite/user123",
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: inviteLink));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Link copied to clipboard!")),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6) ,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.copy, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              "Copy",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // SHARE VIA
              Text(
                "SHARE VIA",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade400,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShareIcon(Icons.chat_bubble, Colors.green.shade500, "WHATSAPP", _shareViaWhatsApp),
                  _buildShareIcon(Icons.message, Colors.teal.shade500, "MESSAGES", _shareViaSMS),
                  _buildShareIcon(Icons.facebook, Colors.blue.shade600, "MESSENGER", _shareViaMessenger),
                  _buildShareIcon(Icons.share, Colors.black87, "MORE", _shareMore),
                ],
              ),
              const SizedBox(height: 30),



              // Bottom Actions
              GestureDetector(
                onTap: _shareMore,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Invite Contacts",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareIcon(IconData icon, Color bgColor, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          )
        ],
      ),
    );
  }
}
