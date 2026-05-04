import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'welcome_screen.dart';
import 'splash_screen.dart';
import 'profile_setup_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'utils/notification_service.dart';
import 'signup_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Skillora',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your email to receive a password reset link.", style: TextStyle(fontSize: 14)),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter your email"), backgroundColor: Colors.red),
                  );
                  return;
                }
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset link sent to ${_emailController.text}"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleEmailSignIn() async {
    setState(() { _isLoading = true; });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      UserCredential userCred;
      
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email and password are required.", style: TextStyle(color: Colors.white)), 
            backgroundColor: Colors.red,
          ),
        );
        setState(() { _isLoading = false; });
        return;
      } else {
        try {
          userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
             throw Exception("No user found for that email. Please sign up.");
          } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
             throw Exception("Wrong password provided.");
          } else {
             rethrow;
          }
        }
      }
      
      if (mounted) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).get();
        if (doc.exists) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const FinalPage()), (route) => false);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen()));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Error: $e")));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _handleEmailSignUp() async {
    setState(() { _isLoading = true; });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      UserCredential userCred;
      
      if (email.isEmpty || password.isEmpty) {
        userCred = await FirebaseAuth.instance.signInAnonymously();
      } else {
        userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      }
      
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen()));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Error: $e")));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() { _isLoading = true; });
    try {
      final auth = FirebaseAuth.instance;
      final UserCredential userCred = await auth.signInAnonymously();
      
      if (mounted) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).get();
        if (doc.exists) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const FinalPage()), (route) => false);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen()));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  "Sign in to continue your learning journey",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 35),
                const Text(
                  "Email Address",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'example@email.com',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Password",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '........',
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      'Forget Password?',
                      style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleEmailSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),

                const SizedBox(height: 25),

                const Center(
                  child: Text(
                    'Or continue with',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 20),

                _isLoading
                    ? const SizedBox()
                    : OutlinedButton.icon(
                        onPressed: _handleGoogleSignIn,
                        icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      
                const SizedBox(height: 30),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}