import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'home_screen.dart'; // To get UserProfile
import 'schedule_session_screen.dart';
import 'models/user_profile.dart';
import 'call_screen.dart';    // Added CallScreen import
import 'widgets/audio_message_bubble.dart';
import 'utils/cloudinary_helper.dart'; // Added Cloudinary Helper
import 'utils/notification_service.dart'; // Added Notification Service

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

  // Recording State
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;

  bool _hasSession = false;
  StreamSubscription<DocumentSnapshot>? _chatSubscription;

  @override
  void initState() {
    super.initState();
    _listenToSessionStatus();
  }

  void _listenToSessionStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final chatId = _getChatId(user.uid, widget.chatUser.id);
    _chatSubscription = FirebaseFirestore.instance.collection('chats').doc(chatId).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        if (mounted) {
          setState(() {
            _hasSession = doc.data()!['hasSession'] ?? false;
            if (_hasSession) _sessionScheduled = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.dispose();
    _timer?.cancel();
    _chatSubscription?.cancel();
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

  Future<void> _handleSessionResponse(DocumentReference msgRef, String status, String notificationText) async {
    try {
      await msgRef.update({'session_status': status});
      
      _sendMessage(
        predefinedText: notificationText,
        type: 'session_$status'
      );
    } catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildSessionBubble(Map<String, dynamic> msg, DocumentReference msgRef, bool isMe) {
    final status = msg['session_status'] ?? 'pending';
    final text = msg['text'] ?? '';
    final type = msg['type'] ?? 'session_request';
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.indigo.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isMe ? Colors.indigo.shade200 : Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: Colors.indigo.shade400),
                const SizedBox(width: 6),
                Text(
                  type == 'session_request' ? "Session Request" 
                  : type == 'session_accepted' ? "Session Accepted" 
                  : "Session Rejected", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900)
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            if (type == 'session_request' && status == 'pending' && !isMe)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleSessionResponse(msgRef, 'accepted', "✅ I've accepted your session request!"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(80, 30)),
                    child: const Text("Accept", style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  OutlinedButton(
                    onPressed: () => _handleSessionResponse(msgRef, 'rejected', "❌ Sorry, I have to reject this session."),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, minimumSize: const Size(80, 30)),
                    child: const Text("Reject", style: TextStyle(fontSize: 12)),
                  ),
                ],
              )
            else if (type == 'session_request' && status == 'accepted')
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Text("✅ Accepted", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else if (type == 'session_request' && status == 'rejected')
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Text("❌ Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else if (type == 'session_request' && status == 'pending' && isMe)
              const Text("Waiting for response...", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildCallBubble(Map<String, dynamic> msg, bool isMe) {
    final type = msg['type'];
    final isVideo = type == 'video_call';
    final text = msg['text'] ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.indigo.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isMe ? Colors.indigo.shade200 : Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isVideo ? Icons.videocam : Icons.phone, size: 16, color: Colors.indigo.shade400),
                const SizedBox(width: 6),
                Text(
                  isVideo ? "Video Call" : "Audio Call", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900)
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;
                final callId = _getChatId(user.uid, widget.chatUser.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallScreen(
                      callID: callId,
                      isVideo: isVideo,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.call, size: 16, color: Colors.white),
              label: const Text("Join Call", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _pickGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading Image...')));
      
      final url = await CloudinaryHelper.uploadFile(image.path, resourceType: 'image');
      if (url != null) {
        _sendMessage(
          predefinedText: "Shared an image", 
          type: 'image', 
          mediaUrl: url
        );
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image.')));
      }
    }
  }

  void _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && mounted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading Document...')));
        
        final url = await CloudinaryHelper.uploadFile(result.files.single.path!, resourceType: 'raw');
        if (url != null) {
          _sendMessage(
            predefinedText: "Shared a document: ${result.files.single.name}", 
            type: 'document',
            mediaUrl: url
          );
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload document.')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _startCall(bool isVideo) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final callId = _getChatId(user.uid, widget.chatUser.id);
    
    // Send a message to Firebase stating that a call was initiated
    _sendMessage(
      predefinedText: isVideo ? "🎥 Video Call Started" : "📞 Audio Call Started",
      type: isVideo ? 'video_call' : 'audio_call'
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          callID: callId,
          isVideo: isVideo,
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _audioPath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _audioPath!,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() => _recordDuration++);
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting record: $e')));
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
        _recordDuration = 0;
      });

      if (path != null) {
        await _uploadAudioAndSend(path);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error stopping record: $e')));
    }
  }

  Future<void> _uploadAudioAndSend(String path) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final file = File(path);
    if (!file.existsSync()) return;

    try {
      // Upload using Cloudinary instead of Firebase Storage
      final url = await CloudinaryHelper.uploadFile(path, resourceType: 'video'); // Cloudinary uses 'video' for audio files
      
      if (url != null) {
        _sendMessage(type: 'audio', mediaUrl: url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cloudinary upload failed. Using local fallback.')));
          _sendMessage(type: 'audio', mediaUrl: path);
        }
      }
    } catch (e) {
      debugPrint("Upload failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Using local file for playback.', style: TextStyle(fontSize: 12))),
        );
        _sendMessage(type: 'audio', mediaUrl: path);
      }
    }
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
      
      String lastMsgText = text;
      if (type == 'image') lastMsgText = '📷 Image';
      if (type == 'document') lastMsgText = '📄 Document';
      if (type == 'audio') lastMsgText = '🎤 Voice Note';
      if (type == 'video_call') lastMsgText = '🎥 Video Call';
      if (type == 'audio_call') lastMsgText = '📞 Audio Call';
      if (type == 'session_request') lastMsgText = '🗓️ Session Request';
      if (type == 'session_accepted') lastMsgText = '✅ Session Accepted';
      if (type == 'session_rejected') lastMsgText = '❌ Session Rejected';

      batch.set(chatRef, {
        'lastMessage': lastMsgText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'users': [user.uid, widget.chatUser.id],
        // Set basic denormalized info so the list can display names instantly without heavy joins (Prototype hack)
        'userName_${widget.chatUser.id}': widget.chatUser.name,
        'userPhoto_${widget.chatUser.id}': widget.chatUser.photo,
        'unread_${widget.chatUser.id}': FieldValue.increment(1),
      }, SetOptions(merge: true));
      
      await batch.commit();

      // Send Push Notification
      final receiverDoc = await FirebaseFirestore.instance.collection('users').doc(widget.chatUser.id).get();
      if (receiverDoc.exists) {
        final data = receiverDoc.data() as Map<String, dynamic>;
        final fcmToken = data['fcmToken'] as String?;
        final isOnline = data['isOnline'] ?? false;
        
        if (fcmToken != null && fcmToken.isNotEmpty && !isOnline) {
          final senderDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final senderName = senderDoc.data()?['name'] ?? 'Someone';
          
          String notifTitle = senderName;
          String notifBody = lastMsgText;
          
          if (type == 'video_call') {
            notifTitle = "Incoming Video Call 🎥";
            notifBody = "from $senderName. Tap here to join!";
          } else if (type == 'audio_call') {
            notifTitle = "Incoming Audio Call 📞";
            notifBody = "from $senderName. Tap here to join!";
          }
          
          NotificationService.sendNotification(fcmToken, notifTitle, notifBody);
        }
      }
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Offline';
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Last seen just now';
    if (diff.inHours < 1) return 'Last seen ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Last seen ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Last seen ${diff.inDays}d ago';
    return 'Last seen ${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _blockUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'blockedUsers': FieldValue.arrayUnion([widget.chatUser.id])
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked.')));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FinalPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error blocking user: $e')));
    }
  }

  void _showReportDialog() {
    String? selectedReason = 'Fake Profile';
    final List<String> reasons = ['Fake Profile', 'Spam', 'Inappropriate behavior', 'Other'];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text("Report & Block"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Why are you reporting this user?"),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {
                      setStateBuilder(() {
                        selectedReason = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _submitReportAndBlock(selectedReason!);
                  },
                  child: const Text("Report", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _submitReportAndBlock(String reason) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // 1. Block user
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(userRef, {
        'blockedUsers': FieldValue.arrayUnion([widget.chatUser.id])
      });
      
      // 2. Report user
      final reportRef = FirebaseFirestore.instance.collection('reports').doc();
      batch.set(reportRef, {
        'reportedBy': user.uid,
        'reportedUser': widget.chatUser.id,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User reported and blocked.')));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FinalPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(widget.chatUser.id).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Loading...", style: TextStyle(fontSize: 10, color: Colors.grey));
                        }
                        
                        final data = snapshot.data?.data() as Map<String, dynamic>?;
                        final isOnline = data?['isOnline'] ?? false;
                        final lastSeen = data?['lastSeen'] as Timestamp?;

                        if (isOnline) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              const Text("Online", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          );
                        } else {
                          return Text(
                            _formatTimestamp(lastSeen),
                            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _hasSession ? Colors.indigo.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.call_outlined, color: _hasSession ? Colors.indigo.shade400 : Colors.grey.shade400, size: 20),
                  onPressed: () {
                    if (!_hasSession) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please create a session first to unlock calls!"),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
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
                    
                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        _sessionScheduled = true;
                      });
                      
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final chatId = _getChatId(user.uid, widget.chatUser.id);
                        FirebaseFirestore.instance.collection('chats').doc(chatId).set({
                          'hasSession': true
                        }, SetOptions(merge: true));
                      }
                      
                      _sendMessage(
                        predefinedText: "Session Request: ${result['topic']}\n${result['date']} at ${result['time']}",
                        type: 'session_request'
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.red.shade400, size: 20),
                  onSelected: (value) {
                    if (value == 'block') {
                      _blockUser();
                    } else if (value == 'report') {
                      _showReportDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Block User'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report_problem, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Block & Report'),
                        ],
                      ),
                    ),
                  ],
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

                              return (type == 'session_request' || type == 'session_accepted' || type == 'session_rejected')
                                ? _buildSessionBubble(msg, currentMsgDoc.reference, isMe)
                                : (type == 'video_call' || type == 'audio_call')
                                  ? _buildCallBubble(msg, isMe)
                                : type == 'audio' && mediaUrl != null
                                  ? AudioMessageBubble(
                                    audioUrl: mediaUrl,
                                    isMe: isMe,
                                    timeText: timeText,
                                    isRead: isRead,
                                  )
                                : Align(
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
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Scaffold(
                                                    backgroundColor: Colors.black,
                                                    appBar: AppBar(
                                                      backgroundColor: Colors.black,
                                                      iconTheme: const IconThemeData(color: Colors.white),
                                                      elevation: 0,
                                                    ),
                                                    body: Center(
                                                      child: InteractiveViewer(
                                                        panEnabled: true,
                                                        minScale: 0.5,
                                                        maxScale: 4.0,
                                                        child: Image.network(mediaUrl),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(mediaUrl, width: 200, height: 150, fit: BoxFit.cover),
                                            ),
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
                                      if (msg['text'] != null && msg['text'].toString().isNotEmpty)
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
                                            // Lock the media/calling features again
                                            final chatId = _getChatId(userAuth.uid, widget.chatUser.id);
                                            await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
                                              'hasSession': false
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
                                      'completedSessions': FieldValue.increment(1),
                                      'coins': FieldValue.increment(1) // Earn 1 coin for teaching
                                    });
                                    // Lock the media/calling features again
                                    final chatId = _getChatId(userAuth.uid, widget.chatUser.id);
                                    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
                                      'hasSession': false
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
                              onPressed: () async {
                                final userAuth = FirebaseAuth.instance.currentUser;
                                if (userAuth != null) {
                                  try {
                                    final doc = await FirebaseFirestore.instance.collection('users').doc(userAuth.uid).get();
                                    final userData = doc.data();
                                    int currentCoins = userData != null ? (userData['coins'] ?? 3) : 3;

                                    if (currentCoins <= 0) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Insufficient Skill Coins! Deliver a skill to earn more."),
                                            backgroundColor: Colors.redAccent,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                      return; // Stop here, restriction applied!
                                    }

                                    // Deduct 1 coin for receiving a skill
                                    await FirebaseFirestore.instance.collection('users').doc(userAuth.uid).update({
                                      'coins': FieldValue.increment(-1)
                                    });

                                    // Send Push Notification if coins run out
                                    if (currentCoins - 1 == 0) {
                                      final fcmToken = userData?['fcmToken'] as String?;
                                      if (fcmToken != null && fcmToken.isNotEmpty) {
                                        NotificationService.sendNotification(
                                          fcmToken,
                                          "Out of Coins! 🪙",
                                          "You have 0 Skill Coins left. Teach a skill to earn more!"
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    debugPrint("Error deducting coin: $e");
                                  }
                                }
                                setState(() {
                                  _skillStatus = SkillStatus.delivered; // Learned
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
                      icon: Icon(Icons.attach_file_outlined, color: _hasSession ? Colors.grey.shade600 : Colors.grey.shade300),
                      onPressed: () {
                        if (!_hasSession) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please schedule a session first to share media!"),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
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

                    if (_isRecording)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Recording... ${Duration(seconds: _recordDuration).toString().split('.').first.substring(2)}",
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
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
                    GestureDetector(
                      onLongPress: () {
                        if (!_hasSession) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please schedule a session first to send voice notes!"),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        _startRecording();
                      },
                      onLongPressUp: () {
                        if (!_hasSession) return;
                        _stopRecording();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none_outlined,
                          color: _hasSession 
                              ? (_isRecording ? Colors.red : Colors.grey.shade600)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    if (!_isRecording)
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
