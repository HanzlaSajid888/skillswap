import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'utils/cloudinary_helper.dart';

class LearnSkillsPage extends StatefulWidget {
  final String name;
  final int age;
  final String bio;
  final List<String> teachSkills;
  final File? image;

  const LearnSkillsPage({
    super.key,
    required this.name,
    required this.age,
    required this.bio,
    required this.teachSkills,
    this.image,
  });

  @override
  State<LearnSkillsPage> createState() => _LearnSkillsPageState();
}

class _LearnSkillsPageState extends State<LearnSkillsPage> {
  List<String> skills = [
    "React", "UI Design",
    "Marketing", "Spanish",
    "Guitar", "Python",
    "Photography", "Public Speaking"
  ];

  List<String> selectedSkills = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredSkills {
    if (_searchQuery.isEmpty) return skills;
    return skills.where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  bool _isSaving = false;

  Future<void> saveUserData() async {
    setState(() { _isSaving = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("You must be logged in to save your profile.");
      }

      String photoUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80'; // default
      
      if (widget.image != null) {
        try {
          final url = await CloudinaryHelper.uploadFile(widget.image!.path, resourceType: 'image');
          if (url != null) {
            photoUrl = url;
          }
        } catch (e) {
          debugPrint("Failed to upload image to Cloudinary, falling back to default. Error: $e");
          // Proceed with the default photoUrl if upload fails
        }
      }

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "id": user.uid,
        "name": widget.name,
        "age": widget.age,
        "bio": widget.bio,
        "photo": photoUrl,
        "teachSkills": widget.teachSkills,
        "learnSkills": selectedSkills,
        "rating": 5.0,
        "coins": 3,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      Row( 
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const LinearProgressIndicator(
                                value: 1.0,
                                backgroundColor: Color(0xFFE0E0E0),
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            "STEP 3 OF 3",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "What do you want to learn?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900, // Extra Bold
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Select the skills you're interested in acquiring.",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search or add a custom skill...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.clear), 
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = "";
                                  });
                                }
                              ) 
                            : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.indigo),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 15),

                      if (_searchQuery.isNotEmpty && !_filteredSkills.any((s) => s.toLowerCase() == _searchQuery.toLowerCase()))
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              skills.insert(0, _searchQuery);
                              selectedSkills.add(_searchQuery);
                              _searchQuery = "";
                              _searchController.clear();
                            });
                            // Unfocus keyboard
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.indigo.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.add_circle, color: Colors.indigo),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Add '$_searchQuery'",
                                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredSkills.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 2.8,
                        ),
                        itemBuilder: (context, index) {
                          final skill = _filteredSkills[index];
                          final isSelected = selectedSkills.contains(skill);

                          return ChoiceChip(
                            label: Center(
                              child: Text(
                                skill,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            labelPadding: EdgeInsets.zero,
                            selected: isSelected,
                            backgroundColor: Colors.white,
                            selectedColor: Colors.indigo.withOpacity(0.1),
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.indigo : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? Colors.indigo : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedSkills.add(skill);
                                } else {
                                  selectedSkills.remove(skill);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await saveUserData();

                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FinalPage(),
                            ),
                            (route) => false,
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving profile: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                            )
                          : const Text(
                              "Finish",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}