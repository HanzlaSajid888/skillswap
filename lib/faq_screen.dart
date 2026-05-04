import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Design system colors
    final Color backgroundColor = const Color(0xFFF8FAFC);
    final Color textColor = const Color(0xFF1E293B);
    final Color subtitleColor = const Color(0xFF64748B);

    final List<Map<String, String>> faqs = [
      {
        "question": "What is Skillora?",
        "answer": "Skillora is a skill-building and sharing platform where users can learn new skills and teach their expertise to others without any monetary transactions."
      },
      {
        "question": "Is Skillora completely free to use?",
        "answer": "Yes! Skillora is based on a skill-for-skill exchange model. You offer a skill you know to learn a skill you want, without any hidden charges or fees."
      },
      {
        "question": "Can beginners teach?",
        "answer": "Absolutely! Everyone has something to share. It could be a language, time management tips, or helpful advice. You don't need to be a professional to help someone grow."
      },
      {
        "question": "How do I schedule a session?",
        "answer": "You can visit a user's profile, check their availability, and send a session request. It's recommended to chat with them first to align your goals."
      },
      {
        "question": "How do the sessions take place?",
        "answer": "Skillora features built-in real-time chat and high-quality video calling, so you can connect and have your sessions seamlessly right inside the app."
      },
    ];

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
          "FAQ",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: Colors.indigo.shade500,
                  collapsedIconColor: Colors.grey.shade400,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Text(
                    faqs[index]["question"]!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        faqs[index]["answer"]!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
