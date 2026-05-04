import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class CallScreen extends StatefulWidget {
  final String callID;
  final bool isVideo;

  const CallScreen({super.key, required this.callID, required this.isVideo});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String _userName = "Loading...";
  final String _userID = FirebaseAuth.instance.currentUser?.uid ?? Random().nextInt(10000).toString();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        setState(() {
          _userName = user.displayName!;
        });
        return;
      }
      
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('name')) {
          setState(() {
            _userName = doc.data()!['name'];
          });
          return;
        }
      } catch (e) {
        debugPrint("Error fetching name: $e");
      }
    }
    setState(() {
      _userName = "User_${_userID.substring(0, 5)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userName == "Loading...") {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 1076319610, // User's App ID
        appSign: "5e293b7794018cbeb8d97f97f8af17a0e04d54fe9930cae5a7e17dc37677ec79", // User's App Sign
        userID: _userID,
        userName: _userName,
        callID: widget.callID,
        config: widget.isVideo ? (ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          ..turnOnCameraWhenJoining = true
          ..turnOnMicrophoneWhenJoining = true
          ..bottomMenuBar.buttons = [
            ZegoCallMenuBarButtonName.toggleCameraButton,
            ZegoCallMenuBarButtonName.toggleMicrophoneButton,
            ZegoCallMenuBarButtonName.switchCameraButton, // explicit
            ZegoCallMenuBarButtonName.hangUpButton,
            ZegoCallMenuBarButtonName.chatButton,
          ]
        ) : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      ),
    );
  }
}
