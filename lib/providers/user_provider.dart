import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  List<UserProfile> _users = [];
  bool _isLoading = false;

  List<UserProfile> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    if (_users.isNotEmpty) return; // Already cached

    _isLoading = true;
    // Allow UI to build before notifying
    Future.microtask(() => notifyListeners());

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      List<String> swipedAndBlocked = [];
      if (currentUser != null) {
        final currentDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (currentDoc.exists) {
          final data = currentDoc.data() as Map<String, dynamic>;
          if (data.containsKey('blockedUsers') && data['blockedUsers'] != null) {
            swipedAndBlocked.addAll(List<String>.from(data['blockedUsers']));
          }
          if (data.containsKey('swipedUsers') && data['swipedUsers'] != null) {
            swipedAndBlocked.addAll(List<String>.from(data['swipedUsers']));
          }
        }
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("users").get();
      
      _users = snapshot.docs.where((doc) {
        // Exclude current user from the swiping list, and exclude any blocked/swiped users
        return doc.id != currentUser?.uid && !swipedAndBlocked.contains(doc.id);
      }).map((doc) {
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
          coins: data['coins'] ?? 3,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeUser(String id) {
    _users.removeWhere((user) => user.id == id);
    notifyListeners();
  }
}
