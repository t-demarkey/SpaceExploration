import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:space_exploration/pages/account_page.dart';
import 'package:space_exploration/pages/register_page.dart';
import 'package:space_exploration/pages/sign_in_button.dart';
import 'package:space_exploration/pages/text_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void forgotPasswordDialog() {
  final TextEditingController resetEmailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(
        controller: resetEmailController,
        decoration: const InputDecoration(
          hintText: 'Enter your email',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            
            Navigator.pop(context); // Close the dialog
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: resetEmailController.text.trim(),
              );
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Password reset email sent!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } on FirebaseAuthException catch (e) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text(e.message ?? 'An error occurred.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: const Text('Send'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}


  void signUserIn() async {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
      
      
      navigator.pop();
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => AccountPage()),
      );
    } on FirebaseAuthException catch (e) {
      navigator.pop();

      if (e.code == 'user-not-found') {
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        wrongPasswordMessage();
      }
    }
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'No account found with this email. Please check the email or register a new account.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Incorrect password. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('assets/photos/spacelogo.png', width: 275,),
                const SizedBox(height: 20),
                const SizedBox(height: 25),
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: forgotPasswordDialog,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(onTap: signUserIn),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(onTap: () {}),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                          color: Colors.greenAccent, // Text color for the button
                          fontWeight: FontWeight.bold,
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
    );
  }
}
