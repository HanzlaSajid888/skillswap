import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'personal_info_screen.dart';
import 'match_screen.dart';
import 'messages_screen.dart'; // Add Messages screen import

import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'models/user_profile.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class FinalPage extends StatefulWidget {
  const FinalPage({super.key});

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> with TickerProviderStateMixin {
  final AppinioSwiperController controller = AppinioSwiperController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
                      const Text(
                        "Skillora",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                    onTap: () { controller.swipeLeft(); },
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
                        final matchedUser = users[_currentIndex];
                        controller.swipeRight();
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchScreen(
                              matchedUser: matchedUser,
                              currentUserPhotoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
                            ),
                          ),
                        );
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
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: UserSearchDelegate(),
                );
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
                Text(
                  "${user.name}, ${user.age}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Review ${user.name}",
            textAlign: TextAlign.center,
          ),
          content: Column(
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
            ],
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
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    
                    // 4. Update user doc
                    transaction.update(userRef, {
                      'averageRating': newAverage,
                      'reviewCount': reviewCount + 1,
                    });
                  });

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
      },
    );
  }
}

class UserSearchDelegate extends SearchDelegate {
  UserSearchDelegate();

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
    return _buildSuggestionsOrResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionsOrResults();
  }

  Widget _buildSuggestionsOrResults() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = provider.users;


        final matches = users.where((user) {
          final nameLower = user.name.toLowerCase();
          final teachesLower = user.skillsTeach.toLowerCase();
          final wantsLower = user.skillsLearn.toLowerCase();
          final queryLower = query.toLowerCase();

          return nameLower.contains(queryLower) ||
              teachesLower.contains(queryLower) ||
              wantsLower.contains(queryLower);
        }).toList();

        if (matches.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final user = matches[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photo),
              ),
              title: Text(user.name),
              subtitle: Text("Teaches: ${user.skillsTeach}\nWants: ${user.skillsLearn}"),
              isThreeLine: true,
              onTap: () {
                // Focus out logic or navigation
                close(context, null);
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