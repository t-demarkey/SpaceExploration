import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:space_exploration/pages/account_page.dart';
import 'package:space_exploration/auth_service.dart';
import 'package:provider/provider.dart';


class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void signup() async {
    final navigator = Navigator.of(context);

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    try {
      final AuthService authService = Provider.of<AuthService>(
        context,
        listen: false,
      );
      await authService.signUpWithEmailandPassword(
        emailController.text,
        passwordController.text,
        firstNameController.text,
        lastNameController.text,
        userNameController.text,
      );
      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AccountPage()),
        (route) => route.isFirst, // Keep only the very first route (HomePage)
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Join the Space Explorer Network",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.greenAccent),
                    decoration: InputDecoration(
                      hintText: "Enter your space ID (email)",
                      hintStyle: TextStyle(color: Colors.greenAccent),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    style: TextStyle(color: Colors.greenAccent),
                    decoration: InputDecoration(
                      hintText: "Create a secure password",
                      hintStyle: TextStyle(color: Colors.greenAccent),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                    style: TextStyle(color: Colors.greenAccent),
                    decoration: InputDecoration(
                      hintText: "Confirm your password",
                      hintStyle: TextStyle(color: Colors.greenAccent),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: userNameController,
                    style: TextStyle(color: Colors.greenAccent),
                    decoration: InputDecoration(
                      hintText: "Enter your username",
                      hintStyle: TextStyle(color: Colors.greenAccent),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: firstNameController,
                    style: TextStyle(color: Colors.greenAccent),
                    decoration: InputDecoration(
                      hintText: "Enter your First name",
                      hintStyle: TextStyle(color: Colors.greenAccent),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: lastNameController,
                    style: TextStyle(color: Colors.greenAccent),
                    decoration: InputDecoration(
                      hintText: "Enter your Last name",
                      hintStyle: TextStyle(color: Colors.greenAccent),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Sign Up for the Mission",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Already on board?",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                          ); // simply removes RegisterPage, reveals SignUp
                        },
                        child: const Text(
                          "Log in now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
