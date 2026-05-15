import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'personal_info_screen.dart';
import 'match_screen.dart';
import 'messages_screen.dart'; // Add Messages screen import

import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'models/user_profile.dart';
import 'utils/notification_service.dart'; // Add Notification Service

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class FinalPage extends StatefulWidget {
  const FinalPage({super.key});

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  final AppinioSwiperController controller = AppinioSwiperController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  void _updateOnlineStatus(bool isOnline) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _processSwipe(UserProfile targetUser, bool isLike) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String currentId = currentUser.uid;
    final String targetId = targetUser.id;

    // Prevent matching with yourself (safeguard)
    if (currentId == targetId) return;

    // 1. Add to swipedUsers array
    await FirebaseFirestore.instance.collection('users').doc(currentId).set({
      'swipedUsers': FieldValue.arrayUnion([targetId])
    }, SetOptions(merge: true));

    if (!isLike) return;

    // 2. It's a LIKE. Add to our likes subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentId)
        .collection('likes')
        .doc(targetId)
        .set({'timestamp': FieldValue.serverTimestamp()});

    // 3. CHECK FOR MUTUAL MATCH
    final targetLikeDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(targetId)
        .collection('likes')
        .doc(currentId)
        .get();

    if (targetLikeDoc.exists) {
      // Mutual Match! Create matches records
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentId)
          .collection('matches')
          .doc(targetId)
          .set({'timestamp': FieldValue.serverTimestamp()});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetId)
          .collection('matches')
          .doc(currentId)
          .set({'timestamp': FieldValue.serverTimestamp()});

      if (mounted) {
        final currentDoc = await FirebaseFirestore.instance.collection('users').doc(currentId).get();
        final currentPhoto = currentDoc.data()?['photo'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80';
        final currentName = currentDoc.data()?['name'] ?? 'Someone';

        // Send push notification to target user about the match
        final targetUserDoc = await FirebaseFirestore.instance.collection('users').doc(targetId).get();
        if (targetUserDoc.exists) {
          final targetData = targetUserDoc.data() as Map<String, dynamic>;
          final fcmToken = targetData['fcmToken'] as String?;
          final isOnline = targetData['isOnline'] ?? false;
          
          if (fcmToken != null && fcmToken.isNotEmpty && !isOnline) {
            NotificationService.sendNotification(
              fcmToken,
              "New Match! 🎉",
              "You and $currentName liked each other's skills!"
            );
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchScreen(
              matchedUser: targetUser,
              currentUserPhotoUrl: currentPhoto,
            ),
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateOnlineStatus(true);
    } else {
      _updateOnlineStatus(false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateOnlineStatus(true);
    
    _slideController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();
    
    // Fetch users via provider after init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    List<UserProfile> users = userProvider.users;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 36, 
                            height: 36, 
                            fit: BoxFit.cover, 
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onLongPress: () {
                          // DEVELOPER SHORTCUT: Long press "Skillora" to test MatchScreen!
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchScreen(
                                matchedUser: UserProfile(
                                  id: 'test_id',
                                  name: 'Test Partner',
                                  age: 24,
                                  photo: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
                                  skillsTeach: 'UI Design',
                                  skillsLearn: 'Flutter',
                                  coins: 0,
                                ),
                                currentUserPhotoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Skillora",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.person),
                        onSelected: (value) {
                          if (value == 'profile') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                            );
                          } else if (value == 'logout') {
                            _updateOnlineStatus(false);
                            FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: Text('Personal Information'),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Text('Sign Out'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: userProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : users.isEmpty
                        ? const Center(child: Text("No more users!"))
                        : SlideTransition(
                            position: _slideAnimation,
                            child: AppinioSwiper(
                              controller: controller,
                              cardCount: users.length,
                              onSwipeBegin: (int previousIndex, int targetIndex, SwiperActivity activity) {},
                              onSwipeEnd: (int previousIndex, int targetIndex, SwiperActivity activity) {
                                _currentIndex = targetIndex;
                                if (activity is Swipe) {
                                  bool isLike = activity.direction == AxisDirection.right;
                                  _processSwipe(users[previousIndex], isLike);
                                }
                              },
                              onEnd: () {}, // Handled by AppinioSwiper logic and removing elements isn't needed visually here yet
                              cardBuilder: (BuildContext context, int index) {
                                return _buildCard(users[index]);
                              },
                            ),
                          ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedBounceButton(
                    onTap: () { 
                      if (users.isNotEmpty && _currentIndex < users.length) {
                        controller.swipeLeft(); 
                      }
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.red.shade100,
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                  AnimatedBounceButton(
                    onTap: () {
                      if (users.isNotEmpty && _currentIndex < users.length) {
                        _showReviewDialog(context, users[_currentIndex]);
                      }
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.amber.shade100,
                      child: const Icon(Icons.star, color: Colors.amber),
                    ),
                  ),
                  AnimatedBounceButton(
                    onTap: () {
                      if (users.isNotEmpty && _currentIndex < users.length) {
                        controller.swipeRight();
                        // Match logic will now trigger automatically inside onSwipeEnd
                      }
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.favorite, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
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
              onPressed: () async {
                final selectedUser = await showSearch<UserProfile?>(
                  context: context,
                  delegate: UserSearchDelegate(),
                );
                if (selectedUser != null && context.mounted) {
                  _showSearchedUserDialog(context, selectedUser);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: Colors.grey.shade400, size: 28),
              onPressed: () {
                Navigator.push(
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

  void _showSearchedUserDialog(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _buildCard(user)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "reject_search_${user.id}",
                    backgroundColor: Colors.red.shade100,
                    elevation: 0,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _processSwipe(user, false);
                    },
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
                  FloatingActionButton(
                    heroTag: "accept_search_${user.id}",
                    backgroundColor: Colors.green.shade100,
                    elevation: 0,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _processSwipe(user, true);
                    },
                    child: const Icon(Icons.favorite, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildCard(UserProfile user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                user.photo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${user.name}, ${user.age}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(user.id).snapshots(),
                      builder: (context, snapshot) {
                        bool isOnline = false;
                        if (snapshot.hasData && snapshot.data?.exists == true) {
                          final data = snapshot.data!.data() as Map<String, dynamic>?;
                          isOnline = data?['isOnline'] ?? false;
                        }
                        if (isOnline) {
                          return Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Online",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Wants: ${user.skillsLearn}",
                    style: TextStyle(color: Colors.pink.shade900, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Teaches: ${user.skillsTeach}",
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, UserProfile user) {
    double rating = 0;
    TextEditingController reviewController = TextEditingController();
    String? selectedBadge;
    final List<Map<String, String>> badges = [
      {'id': 'Top Mentor', 'icon': '🌟', 'label': 'Top Mentor'},
      {'id': 'Fast Responder', 'icon': '⚡', 'label': 'Fast Responder'},
      {'id': 'Good Communicator', 'icon': '🗣️', 'label': 'Good Communicator'},
      {'id': 'Creative Solver', 'icon': '💡', 'label': 'Creative Solver'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Review ${user.name}",
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) {
                        rating = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write your review here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Endorse with a Badge (Optional)",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: badges.map((badge) {
                        final isSelected = selectedBadge == badge['id'];
                        return ChoiceChip(
                          label: Text("${badge['icon']} ${badge['label']}"),
                          selected: isSelected,
                          onSelected: (selected) {
                            setStateBuilder(() {
                              selectedBadge = selected ? badge['id'] : null;
                            });
                          },
                          selectedColor: Colors.indigo.shade100,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.indigo.shade900 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () { Navigator.pop(context); },
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final userRef = FirebaseFirestore.instance.collection('users').doc(user.id);

                      await FirebaseFirestore.instance.runTransaction((transaction) async {
                        // 1. Read current user doc
                        DocumentSnapshot userDoc = await transaction.get(userRef);
                        if (!userDoc.exists) {
                          throw Exception("User does not exist!");
                        }
                        
                        final data = userDoc.data() as Map<String, dynamic>;
                        double currentRating = (data['averageRating'] ?? 0.0).toDouble();
                        int reviewCount = (data['reviewCount'] ?? 0).toInt();
                        
                        // 2. Calculate new average
                        double newAverage = ((currentRating * reviewCount) + rating) / (reviewCount + 1);
                        
                        // 3. Add to subcollection
                        DocumentReference newReviewRef = userRef.collection('reviews').doc();
                        transaction.set(newReviewRef, {
                          'rating': rating,
                          'review': reviewController.text,
                          'badge': selectedBadge,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        
                        // 4. Update user doc
                        final Map<String, dynamic> updates = {
                          'averageRating': newAverage,
                          'reviewCount': reviewCount + 1,
                        };
                        
                        Map<String, dynamic> currentBadges = data['badges'] != null ? Map<String, dynamic>.from(data['badges']) : {};
                        
                        if (selectedBadge != null) {
                          String badgeKey = selectedBadge!;
                          currentBadges[badgeKey] = (currentBadges[badgeKey] ?? 0) + 1;
                          updates['badges'] = currentBadges;
                        }
                        
                        transaction.update(userRef, updates);
                      });

                      // Send Push Notification
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      if (currentUid != null) {
                        final currentDoc = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
                        final currentName = currentDoc.data()?['name'] ?? 'Someone';
                        
                        final targetUserDoc = await FirebaseFirestore.instance.collection('users').doc(user.id).get();
                        if (targetUserDoc.exists) {
                          final targetData = targetUserDoc.data() as Map<String, dynamic>;
                          final fcmToken = targetData['fcmToken'] as String?;
                          final isOnline = targetData['isOnline'] ?? false;
                          
                          if (fcmToken != null && fcmToken.isNotEmpty && !isOnline) {
                            String notifBody = "Left you a $rating-star review!";
                            if (selectedBadge != null) {
                              notifBody += " and awarded you '$selectedBadge'.";
                            }
                            
                            NotificationService.sendNotification(
                              fcmToken,
                              "New Review! ⭐",
                              "$currentName $notifBody"
                            );
                          }
                        }
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Review submitted for ${user.name}!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error saving review: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

class UserSearchDelegate extends SearchDelegate<UserProfile?> {
  UserSearchDelegate();

  void _saveSearchQuery() async {
    if (query.trim().isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'searchHistory': FieldValue.arrayUnion([query.trim()]),
      }, SetOptions(merge: true));
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _saveSearchQuery();
    return _buildSuggestionsOrResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return const SizedBox.shrink();
      
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final List<dynamic> searchHistory = data?['searchHistory'] ?? [];
          final recentSearches = searchHistory.reversed.toList();
          
          if (recentSearches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("No recent searches", style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final term = recentSearches[index].toString();
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(term, style: const TextStyle(color: Colors.black87)),
                trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
                onTap: () {
                  query = term;
                  showResults(context);
                },
              );
            },
          );
        },
      );
    }
    return _buildSuggestionsOrResults();
  }

  Widget _buildSuggestionsOrResults() {
    final queryLower = query.toLowerCase().trim();
    if (queryLower.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final allUsersDocs = snapshot.data!.docs;
        final currentUid = FirebaseAuth.instance.currentUser?.uid;

        final matches = allUsersDocs.where((doc) {
          if (doc.id == currentUid) return false;
          final data = doc.data() as Map<String, dynamic>;
          final nameLower = (data['name'] ?? '').toString().toLowerCase();
          final teachesLower = data.containsKey('teachSkills') 
              ? ((data['teachSkills'] as List?)?.join(', ') ?? '').toLowerCase() 
              : '';
          final wantsLower = data.containsKey('learnSkills') 
              ? ((data['learnSkills'] as List?)?.join(', ') ?? '').toLowerCase() 
              : '';

          return nameLower.contains(queryLower) ||
                 teachesLower.contains(queryLower) ||
                 wantsLower.contains(queryLower);
        }).toList();

        if (matches.isEmpty) {
          return const Center(child: Text('No users found for this search.'));
        }

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final doc = matches[index];
            final data = doc.data() as Map<String, dynamic>;
            final photo = data['photo'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80';
            final name = data['name'] ?? 'Unknown';
            final skillsTeach = data.containsKey('teachSkills') ? ((data['teachSkills'] as List?)?.join(', ') ?? '') : '';
            final skillsLearn = data.containsKey('learnSkills') ? ((data['learnSkills'] as List?)?.join(', ') ?? '') : '';

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(photo),
              ),
              title: Text(name),
              subtitle: Text("Teaches: $skillsTeach\nWants: $skillsLearn"),
              isThreeLine: true,
              onTap: () {
                _saveSearchQuery();
                final userProfile = UserProfile(
                  id: doc.id,
                  name: name,
                  age: data['age'] ?? 0,
                  photo: photo,
                  skillsTeach: skillsTeach,
                  skillsLearn: skillsLearn,
                  coins: data['coins'] ?? 3,
                );
                close(context, userProfile);
              },
            );
          },
        );
      },
    );
  }
}

class AnimatedBounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedBounceButton({super.key, required this.child, required this.onTap});

  @override
  State<AnimatedBounceButton> createState() => _AnimatedBounceButtonState();
}

class _AnimatedBounceButtonState extends State<AnimatedBounceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
         _controller.reverse().then((value) => widget.onTap());
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}