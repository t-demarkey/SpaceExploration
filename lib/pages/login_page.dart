import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:space_exploration/firebase_options.dart';
import 'package:space_exploration/pages/account_page.dart';
import 'package:space_exploration/pages/sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool firebaseReady = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_) {
      setState(() => firebaseReady = true);

      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => user != null ? AccountPage() : const SignUp(),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            !firebaseReady
                ? const CircularProgressIndicator()
                : const SizedBox(), 
      ),
    );
  }
}
