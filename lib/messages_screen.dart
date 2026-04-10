import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; // For FinalPage and UserProfile
import 'personal_info_screen.dart';
import 'chat_screen.dart';
import 'models/user_profile.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";
    final DateTime dt = (timestamp as Timestamp).toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0 && now.day == dt.day) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } else if (diff.inDays < 7) {
      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      return days[dt.weekday - 1];
    } else {
      return "${dt.day}/${dt.month}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF8FAFC);
    final Color textColor = const Color(0xFF1E293B);
    final Color subtitleColor = const Color(0xFF64748B);
    final Color primaryColor = Colors.indigo;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Messages",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add, color: primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search conversations...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Conversations List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('users', arrayContains: FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No active conversations yet.",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      );
                    }
                    
                    final sortedDocs = snapshot.data!.docs.toList();
                    sortedDocs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['lastMessageTime'] as Timestamp?;
                      final bTime = bData['lastMessageTime'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });

                    return ListView.separated(
                      itemCount: sortedDocs.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: Colors.grey.shade100, height: 1),
                      ),
                      itemBuilder: (context, index) {
                        final chatDoc = sortedDocs[index].data() as Map<String, dynamic>;
                        final currentUid = FirebaseAuth.instance.currentUser?.uid;
                        
                        final users = List<dynamic>.from(chatDoc['users'] ?? []);
                        users.remove(currentUid);
                        final otherUid = users.isNotEmpty ? users.first : 'Unknown';
                        
                        final convo = {
                          "id": otherUid,
                          "name": chatDoc['userName_$otherUid'] ?? "Unknown User",
                          "photo": chatDoc['userPhoto_$otherUid'] ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
                          "message": chatDoc['lastMessage'] ?? "📎 Attached file",
                          "time": _formatTime(chatDoc['lastMessageTime']),
                          "unread": chatDoc['unread_$currentUid'] ?? 0,
                          "isOnline": false,
                        };
                        
                        return _buildConversationItem(convo, textColor, subtitleColor, primaryColor);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.grey.shade400, size: 28),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: UserSearchDelegate(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble, color: Colors.indigo, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: Colors.grey.shade400, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> convo, Color textColor, Color subtitleColor, Color primaryColor) {
    bool hasUnread = convo['unread'] > 0;
    
    return InkWell(
      onTap: () {
        // Create a UserProfile for the ChatScreen using the dynamic data
        final userProfile = UserProfile(
          id: convo['id'], 
          name: convo['name'],
          age: 25, // Fallback
          photo: convo['photo'],
          skillsTeach: "SKILL SWAPPER", // Fallback
          skillsLearn: "ACTIVE", // Fallback
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatUser: userProfile),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Avatar with Online Badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(convo['photo']),
                ),
                if (convo['isOnline'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            
            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    convo['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    convo['message'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                      color: hasUnread ? textColor : subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            
            // Time and Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  convo['time'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: hasUnread ? primaryColor : subtitleColor,
                  ),
                ),
                const SizedBox(height: 8),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      convo['unread'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 24), // Placeholder to keep alignment
              ],
            ),
          ],
        ),
      ),
    );
  }
}
