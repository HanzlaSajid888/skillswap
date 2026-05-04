import 'package:flutter/material.dart';

class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF8FAFC);
    final Color textColor = const Color(0xFF1E293B);

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
          "App Guide",
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How Skillora Works",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Follow these simple steps to start learning and sharing your skills with the community.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 30),
              
              _buildTimelineItem(
                isFirst: true,
                isLast: false,
                icon: Icons.person_outline,
                iconColor: Colors.purple.shade600,
                step: "Step 1",
                title: "Complete Your Profile \u{1F4DD}",
                description: "Add the skills you already know and the ones you want to learn to help others find you.",
              ),
              _buildTimelineItem(
                isFirst: false,
                isLast: false,
                icon: Icons.search_rounded,
                iconColor: Colors.blue.shade600,
                step: "Step 2",
                title: "Find Your Match \u{1F50D}",
                description: "Browse the home screen or use search to find users who teach what you want to learn.",
              ),
              _buildTimelineItem(
                isFirst: false,
                isLast: false,
                icon: Icons.chat_bubble_outline,
                iconColor: Colors.teal.shade600,
                step: "Step 3",
                title: "Connect & Chat \u{1F4AC}",
                description: "Send a message to your potential mentor or student. Discuss availability and align your goals.",
              ),
              _buildTimelineItem(
                isFirst: false,
                isLast: true,
                icon: Icons.videocam_outlined,
                iconColor: Colors.indigo.shade600,
                step: "Step 4",
                title: "Start Learning \u{1F680}",
                description: "Schedule your session and use our built-in video calling to exchange knowledge seamlessly.",
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isFirst,
    required bool isLast,
    required IconData icon,
    required Color iconColor,
    required String step,
    required String title,
    required String description,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline graphic
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 20,
                  color: isFirst ? Colors.transparent : Colors.grey.shade300,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
