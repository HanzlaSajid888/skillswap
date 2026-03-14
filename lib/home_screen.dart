import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'personal_info_screen.dart';
import 'match_screen.dart';
import 'messages_screen.dart'; // Add Messages screen import

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String photo;
  final String skillsTeach;
  final String skillsLearn;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.photo,
    required this.skillsTeach,
    required this.skillsLearn,
  });
}

class FinalPage extends StatefulWidget {
  const FinalPage({super.key});

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  final AppinioSwiperController controller = AppinioSwiperController();

  List<UserProfile> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Firestore se users fetch karne ka function
  void fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("users").get();

      setState(() {
        users = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return UserProfile(
            id: doc.id,
            name: data['name'] ?? 'Unknown',
            age: data['age'] ?? 0,
            photo: data['photo'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
            skillsTeach: data.containsKey('teachSkills') 
                ? ((data['teachSkills'] as List?)?.join(', ') ?? '') 
                : '',
            skillsLearn: data.containsKey('learnSkills') 
                ? ((data['learnSkills'] as List?)?.join(', ') ?? '') 
                : '',
          );
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.indigo.shade100,
                        child: const Icon(Icons.people, color: Colors.indigo),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "SkillSwap",
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
                child: users.isEmpty
                    ? const Center(child: Text("No more users!"))
                    : AppinioSwiper(
                  controller: controller,
                  cardCount: users.length,
                  onSwipeBegin: (int previousIndex, int targetIndex, SwiperActivity activity) {},
                  onSwipeEnd: (int previousIndex, int targetIndex, SwiperActivity activity) {},
                  onEnd: () {
                    setState(() {
                      users.clear();
                    });
                  },
                  cardBuilder: (BuildContext context, int index) {
                    return _buildCard(users[index]);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () { controller.swipeLeft(); },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.red.shade100,
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (users.isNotEmpty) {
                        _showReviewDialog(context, users.first);
                      }
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.amber.shade100,
                      child: const Icon(Icons.star, color: Colors.amber),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (users.isNotEmpty) {
                        final matchedUser = users.first;
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
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.id)
                      .collection('reviews')
                      .add({
                    'rating': rating,
                    'review': reviewController.text,
                    'timestamp': FieldValue.serverTimestamp(),
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
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection("users").get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<UserProfile> users = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return UserProfile(
            id: doc.id,
            name: data['name'] ?? 'Unknown',
            age: data['age'] ?? 0,
            photo: data['photo'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
            skillsTeach: data.containsKey('teachSkills') 
                ? (data['teachSkills'] as List).join(', ') 
                : 'Flutter, Dart',
            skillsLearn: data.containsKey('wantSkills') 
                ? (data['wantSkills'] as List).join(', ') 
                : 'UI/UX, Firebase',
          );
        }).toList();

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