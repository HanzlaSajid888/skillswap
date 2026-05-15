import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'faq_screen.dart';
import 'app_guide_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          "Help & Support",
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
                  color: Colors.lightBlue.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.lightBlue.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                           BoxShadow(
                             color: Colors.blue.shade600.withOpacity(0.3),
                             blurRadius: 10,
                             offset: const Offset(0, 4),
                           )
                        ]
                      ),
                      child: const Icon(Icons.help_outline, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "How can we help?",
                            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Find answers or talk to our experts.",
                            style: TextStyle(color: subtitleColor, fontSize: 12),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // HELP
              buildSectionHeader(Icons.help_outline, "HELP", Colors.blue.shade600),
              const SizedBox(height: 10),
              buildBoxContainer([
                buildTile(
                  icon: Icons.help_outline, iconColor: Colors.blue, iconBgColor: Colors.blue.shade50,
                  title: "FAQ", subtitle: "Common questions & answers", 
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FaqScreen(),
                      ),
                    );
                  },
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.menu_book_outlined, iconColor: Colors.lightBlue, iconBgColor: Colors.lightBlue.shade50,
                  title: "App Guide", subtitle: "Learn how to use Skillora", 
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppGuideScreen(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 30),

              // SUPPORT
              buildSectionHeader(Icons.headset_mic_outlined, "SUPPORT", Colors.deepPurple.shade400),
              const SizedBox(height: 10),
              buildBoxContainer([
                buildTile(
                  icon: Icons.email_outlined, iconColor: Colors.purple, iconBgColor: Colors.purple.shade50,
                  title: "Contact Support", subtitle: "ranahunzlaa.huni777@gmail.com",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'ranahunzlaa.huni777@gmail.com',
                      query: Uri.encodeFull('subject=Skillora User Support'),
                    );
                    await launchUrl(emailLaunchUri);
                  },
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.error_outline, iconColor: Colors.red, iconBgColor: Colors.red.shade50,
                  title: "Report a Problem", subtitle: "Let us know if something is wrong",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'ranahunzlaa.huni777@gmail.com',
                      query: Uri.encodeFull('subject=Skillora Bug Report&body=Please describe the problem you are facing:\n\n'),
                    );
                    await launchUrl(emailLaunchUri);
                  },
                ),
              ]),
              const SizedBox(height: 30),

              // FEEDBACK
              buildSectionHeader(Icons.favorite_border, "FEEDBACK", Colors.deepOrange.shade400),
              const SizedBox(height: 10),
              buildBoxContainer([
                buildTile(
                  icon: Icons.favorite_border, iconColor: Colors.orange, iconBgColor: Colors.orange.shade50,
                  title: "Send Feedback", subtitle: "Help us improve Skillora",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => const FeedbackSheetWidget(),
                    );
                  },
                ),
                buildDivider(),
                buildTile(
                  icon: Icons.star_border, iconColor: Colors.amber, iconBgColor: Colors.amber.shade50,
                  title: "Rate the App", subtitle: "Show us some love on the store",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    int selectedRating = 0;
                    final outerContext = context;
                    showDialog(
                      context: outerContext,
                      builder: (dialogContext) {
                        return StatefulBuilder(
                          builder: (stateContext, setState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 40),
                                    const SizedBox(height: 10),
                                    const Text("Rate Skillora", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  ],
                                ),
                              ),
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(4, (index) {
                                  return IconButton(
                                    icon: Icon(
                                      index < selectedRating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedRating = index + 1;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  );
                                }).map((widget) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: widget)).toList(),
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    if(selectedRating > 0) {
                                      try {
                                        final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
                                        await FirebaseFirestore.instance.collection('app_ratings').add({
                                          'rating': selectedRating,
                                          'userId': uid,
                                          'timestamp': FieldValue.serverTimestamp(),
                                        });

                                        if (outerContext.mounted) {
                                          ScaffoldMessenger.of(outerContext).showSnackBar(
                                            SnackBar(
                                              content: Text("Thank you for your $selectedRating-star rating!"),
                                              backgroundColor: Colors.amber.shade700,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (outerContext.mounted) {
                                          ScaffoldMessenger.of(outerContext).showSnackBar(
                                            SnackBar(
                                              content: Text("Failed to submit rating: $e"),
                                              backgroundColor: Colors.red.shade600,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ]),
              const SizedBox(height: 30),


              Center(
                child: Text(
                  "Skillora version 1.2.4 (Build 42)",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
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

class FeedbackSheetWidget extends StatefulWidget {
  const FeedbackSheetWidget({super.key});

  @override
  State<FeedbackSheetWidget> createState() => _FeedbackSheetWidgetState();
}

class _FeedbackSheetWidgetState extends State<FeedbackSheetWidget> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await FirebaseFirestore.instance.collection('app_feedback').add({
        'message': feedback,
        'userId': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Thank you for your feedback!"),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to send feedback. Please try again."),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Send Feedback",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "We'd love to hear your thoughts, suggestions, or bug reports.",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Type your feedback here...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.indigo.shade500, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Submit Feedback", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
