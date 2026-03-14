import 'package:flutter/material.dart';
import 'home_screen.dart'; // To get UserProfile
import 'schedule_session_screen.dart';

enum SkillStatus { none, inProgress, delivered, stoppedTeaching, stoppedLearning }

class ChatScreen extends StatefulWidget {
  final UserProfile chatUser;

  const ChatScreen({super.key, required this.chatUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _sessionScheduled = false;
  SkillStatus _skillStatus = SkillStatus.none;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          padding: const EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const FinalPage()),
                    (route) => false,
                  );
                },
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.chatUser.photo),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.chatUser.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      widget.chatUser.skillsTeach.toUpperCase(), // Assuming first skill or combined skills
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey, // Adjust color to match ref
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.calendar_today_outlined, color: Colors.indigo.shade400, size: 20),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleSessionScreen(chatUser: widget.chatUser),
                      ),
                    );
                    
                    if (result == true) {
                      setState(() {
                        _sessionScheduled = true;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Date timestamp
                    Text(
                      "TODAY",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade400,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Status Badge
                    if (_skillStatus == SkillStatus.inProgress)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "SKILL IN PROGRESS",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_skillStatus == SkillStatus.delivered)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "SKILL DELIVERED",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_skillStatus == SkillStatus.stoppedTeaching)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "STOP TEACHING",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_skillStatus == SkillStatus.stoppedLearning)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "STOP LEARNING",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // Empty state center message
                    Text(
                      "No messages yet. Say hi to start swapping!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // Conditional Buttons Area
            if (_sessionScheduled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _skillStatus == SkillStatus.delivered
                          ? OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _skillStatus = SkillStatus.stoppedLearning;
                                });
                              },
                              icon: const Icon(Icons.stop, size: 16, color: Colors.white),
                              label: const Text(
                                "STOP",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.red.shade600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _skillStatus = SkillStatus.inProgress;
                                });
                              },
                              icon: Icon(Icons.outbox,
                                  size: 16,
                                  color: _skillStatus == SkillStatus.inProgress
                                      ? Colors.white
                                      : Colors.indigo.shade400),
                              label: Text(
                                "DELIVER SKILL",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _skillStatus == SkillStatus.inProgress
                                        ? Colors.white
                                        : Colors.indigo.shade400,
                                    letterSpacing: 0.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _skillStatus == SkillStatus.inProgress
                                    ? Colors.indigo.shade600
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                    color: _skillStatus == SkillStatus.inProgress
                                        ? Colors.indigo.shade600
                                        : Colors.indigo.shade100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _skillStatus == SkillStatus.inProgress
                          ? OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _skillStatus = SkillStatus.stoppedTeaching;
                                });
                              },
                              icon: const Icon(Icons.stop, size: 16, color: Colors.white),
                              label: const Text(
                                "STOP",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.red.shade600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _skillStatus = SkillStatus.delivered;
                                });
                              },
                              icon: Icon(Icons.check,
                                  size: 16,
                                  color: _skillStatus == SkillStatus.delivered
                                      ? Colors.white
                                      : Colors.green.shade400),
                              label: Text(
                                "RECEIVE SKILL",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _skillStatus == SkillStatus.delivered
                                        ? Colors.white
                                        : Colors.green.shade400,
                                    letterSpacing: 0.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _skillStatus == SkillStatus.delivered
                                    ? Colors.green.shade600
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                    color: _skillStatus == SkillStatus.delivered
                                        ? Colors.green.shade600
                                        : Colors.green.shade100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

            // Bottom Input Area
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
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
                    IconButton(
                      icon: Icon(Icons.image_outlined, color: Colors.grey.shade400),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.videocam_outlined, color: Colors.grey.shade400),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_outlined, color: Colors.indigo.shade200),
                      onPressed: () {},
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
}
