import 'package:flutter/material.dart';

class LearningDashboardScreen extends StatefulWidget {
  const LearningDashboardScreen({super.key});

  @override
  State<LearningDashboardScreen> createState() => _LearningDashboardScreenState();
}

class _LearningDashboardScreenState extends State<LearningDashboardScreen> {
  // Current values for progress bars (simulating state)
  double reactProgress = 0.75;
  double spanishProgress = 0.40;
  double designProgress = 1.0;

  @override
  Widget build(BuildContext context) {
    // Colors from reference
    final Color backgroundColor = const Color(0xFFF1F5F9);
    final Color textColor = const Color(0xFF1E293B);
    final Color subtitleColor = const Color(0xFF64748B);
    final Color primaryColor = Colors.indigo;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Learning Dashboard",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Stats Row
              Row(
                children: [
                   Expanded(
                    child: _buildStatBox(
                      "COMPLETED",
                      "3",
                      "Skills",
                      Colors.indigo.shade50,
                      Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatBox(
                      "IN PROGRESS",
                      "5",
                      "Skills",
                      Colors.green.shade50,
                      Colors.green.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Learning Streak Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827), // Dark navy/black
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "LEARNING STREAK",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "12 Days Strong!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Small flame or icon decoration on the right
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Active Learning Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ACTIVE LEARNING",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: subtitleColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "View History",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Learning Cards
              _buildLearningCard(
                category: "TECH",
                title: "React Fundamentals",
                progressValue: reactProgress,
                progressColor: primaryColor,
                onComplete: () {
                   setState(() {
                     reactProgress = 1.0;
                   });
                },
              ),
              const SizedBox(height: 15),

              _buildLearningCard(
                category: "LANGUAGE",
                title: "Spanish Basics",
                progressValue: spanishProgress,
                progressColor: primaryColor,
                onComplete: () {
                   setState(() {
                     spanishProgress = 1.0;
                   });
                },
              ),
              const SizedBox(height: 15),

               _buildLearningCard(
                category: "DESIGN",
                title: "UI Design Principles",
                progressValue: designProgress,
                progressColor: Colors.green, // 100% shows green in ref
                onComplete: () {}, // Already completed
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String number, String subtitle, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                number,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard({
    required String category,
    required String title,
    required double progressValue,
    required Color progressColor,
    required VoidCallback onComplete,
  }) {
    bool isCompleted = progressValue >= 1.0;
    String percentageText = "${(progressValue * 100).toInt()}%";

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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.transparent,
                       border: Border.all(color: Colors.grey.shade200),
                       borderRadius: BorderRadius.circular(6),
                     ),
                     child: Text(
                       category,
                       style: TextStyle(
                         fontSize: 10,
                         fontWeight: FontWeight.bold,
                         color: Colors.indigo.shade300,
                         letterSpacing: 1.0,
                       ),
                     ),
                   ),
                   const SizedBox(height: 15),
                   Text(
                     title,
                     style: const TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                       color: Color(0xFF1E293B),
                     ),
                   ),
                 ],
               ),
               Text(
                 percentageText,
                 style: const TextStyle(
                   fontSize: 22,
                   fontWeight: FontWeight.w900,
                   color: Colors.indigo, // Always indigo in screenshot
                 ),
               ),
            ],
          ),
          const SizedBox(height: 15),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isCompleted ? null : onComplete,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isCompleted ? Colors.transparent : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: isCompleted ? Colors.grey.shade50 : Colors.white,
              ),
              child: Text(
                isCompleted ? "Completed" : "Mark as Completed",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
