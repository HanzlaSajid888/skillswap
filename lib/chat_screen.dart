import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart'; // To get UserProfile
import 'schedule_session_screen.dart';
import 'models/user_profile.dart';

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

  Widget _buildAttachmentOption(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // close bottom sheet
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _pickGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      // BYPASS: Send a hardcoded image link instead of uploading to Firebase Storage
      _sendMessage(
        predefinedText: "Shared an image", 
        type: 'image', 
        mediaUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?auto=format&fit=crop&w=800&q=80'
      );
    }
  }

  void _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && mounted) {
        // BYPASS: Send a dummy document message
        _sendMessage(
          predefinedText: "Shared a document: ${result.files.single.name}", 
          type: 'document'
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _startCall(bool isVideo) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isVideo ? 'Starting Video Call...' : 'Starting Audio Call...')));
  }

  void _recordAudio() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recording Audio (Tap to stop)...')));
  }

  String _getChatId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join('_');
  }

  void _sendMessage({String? predefinedText, String type = 'text', String? mediaUrl}) async {
    final text = predefinedText ?? _messageController.text.trim();
    if (text.isEmpty && type == 'text') return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    if (predefinedText == null) _messageController.clear();
    
    final chatId = _getChatId(user.uid, widget.chatUser.id);
    
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // 1. Add Message
      final messageRef = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').doc();
      batch.set(messageRef, {
        'text': text,
        'type': type,
        'mediaUrl': mediaUrl,
        'senderId': user.uid,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // 2. Update Parent Chat Document
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
      batch.set(chatRef, {
        'lastMessage': type == 'text' ? text : (type == 'image' ? '📷 Image' : '📄 Document'),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'users': [user.uid, widget.chatUser.id],
        // Set basic denormalized info so the list can display names instantly without heavy joins (Prototype hack)
        'userName_${widget.chatUser.id}': widget.chatUser.name,
        'userPhoto_${widget.chatUser.id}': widget.chatUser.photo,
        'unread_${widget.chatUser.id}': FieldValue.increment(1),
      }, SetOptions(merge: true));
      
      await batch.commit();
    } catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending msg: $e')));
    }
  }
  
  // Clear unreads when we open/view the chat
  void _clearUnread() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final chatId = _getChatId(user.uid, widget.chatUser.id);
    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'unread_${user.uid}': 0,
    }, SetOptions(merge: true));
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
                  icon: Icon(Icons.call_outlined, color: Colors.indigo.shade400, size: 20),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildAttachmentOption(Icons.phone, Colors.green, "Audio Call", () => _startCall(false)),
                            _buildAttachmentOption(Icons.videocam, Colors.blue, "Video Call", () => _startCall(true)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
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
                          borderRadius: BorderRadius.circular(30),
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
                          borderRadius: BorderRadius.circular(30),
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
                          borderRadius: BorderRadius.circular(30),
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
                          borderRadius: BorderRadius.circular(30),
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
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .doc(_getChatId(FirebaseAuth.instance.currentUser?.uid ?? '', widget.chatUser.id))
                            .collection('messages')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final messages = snapshot.data!.docs;
                          if (messages.isEmpty) {
                            return Center(
                              child: Text(
                                "No messages yet. Say hi to start swapping!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            reverse: true, // Show latest messages at the bottom
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final currentMsgDoc = messages[index];
                              final msg = currentMsgDoc.data() as Map<String, dynamic>;
                              final isMe = msg['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                              final isRead = msg['isRead'] ?? false;
                              final type = msg['type'] ?? 'text';
                              final mediaUrl = msg['mediaUrl'];
                              
                              // Check and mark as read if it's someone else's message and we haven't read it
                              if (!isMe && !isRead) {
                                currentMsgDoc.reference.update({'isRead': true});
                                _clearUnread();
                              }

                              // Extract time cleanly
                              String timeText = "";
                              if (msg['timestamp'] != null) {
                                final DateTime dt = (msg['timestamp'] as Timestamp).toDate();
                                timeText = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                              }

                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.indigo : Colors.grey.shade200,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(15),
                                      topRight: const Radius.circular(15),
                                      bottomLeft: isMe ? const Radius.circular(15) : const Radius.circular(0),
                                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(15),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      if (type == 'image' && mediaUrl != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(mediaUrl, width: 200, height: 150, fit: BoxFit.cover),
                                          ),
                                        ),
                                      if (type == 'document')
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.insert_drive_file, color: isMe ? Colors.white : Colors.indigo, size: 24),
                                              const SizedBox(width: 8),
                                              Text("Document", style: TextStyle(color: isMe ? Colors.white : Colors.indigo, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      Text(
                                        msg['text'] ?? '',
                                        style: TextStyle(
                                          color: isMe ? Colors.white : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            timeText,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isMe ? Colors.white70 : Colors.black54,
                                            ),
                                          ),
                                          if (isMe) const SizedBox(width: 4),
                                          if (isMe) 
                                            Icon(
                                              isRead ? Icons.done_all : Icons.check, 
                                              size: 14, 
                                              color: isRead ? Colors.blueAccent : Colors.white70
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
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
                              onPressed: () async {
                                final userAuth = FirebaseAuth.instance.currentUser;
                                if (userAuth != null) {
                                  try {
                                    await FirebaseFirestore.instance.collection('users').doc(userAuth.uid).update({
                                      'completedSessions': FieldValue.increment(1)
                                    });
                                  } catch (e) {
                                    debugPrint("Error recording stop learning: $e");
                                  }
                                }
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
                                  borderRadius: BorderRadius.circular(12),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _skillStatus == SkillStatus.inProgress
                          ? OutlinedButton.icon(
                              onPressed: () async {
                                final userAuth = FirebaseAuth.instance.currentUser;
                                if (userAuth != null) {
                                  try {
                                    await FirebaseFirestore.instance.collection('users').doc(userAuth.uid).update({
                                      'completedSessions': FieldValue.increment(1)
                                    });
                                  } catch (e) {
                                    debugPrint("Error recording stop teaching: $e");
                                  }
                                }
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
                                  borderRadius: BorderRadius.circular(12),
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
                                  borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
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
                      icon: Icon(Icons.attach_file_outlined, color: Colors.grey.shade400),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildAttachmentOption(Icons.image, Colors.purple, "Gallery", _pickGallery),
                                _buildAttachmentOption(Icons.picture_as_pdf, Colors.red, "Document", _pickDocument),
                              ],
                            ),
                          ),
                        );
                      },
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
                      icon: Icon(Icons.mic_none_outlined, color: Colors.grey.shade400),
                      onPressed: _recordAudio,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.indigo),
                      onPressed: _sendMessage,
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
