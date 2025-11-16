import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:space_exploration/pages/edit_profile.dart';
import 'package:space_exploration/pages/learn.dart';
import 'package:space_exploration/pages/login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Page")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error fetching data"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No user data found"));
          }

          var userData = snapshot.data!;
          String firstName = userData['firstName'] ?? "No First Name";
          String lastName = userData['lastName'] ?? "No Last Name";
          String userName = userData['userName'] ?? "No Username";
          int totalPoints = userData['points'] ?? 0;
          String? profilePhotoPath = userData['profilePhoto'];

          Widget profilePhotoWidget;

          if (profilePhotoPath != null) {
            profilePhotoWidget = CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage(profilePhotoPath),
              backgroundColor: Colors.grey[300],
            );
          } else {
            profilePhotoWidget = const CircleAvatar(
              radius: 100,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 100, color: Colors.white),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                profilePhotoWidget,
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      firstName,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      lastName,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(fontSize: 20, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total Points: $totalPoints',
                  style: const TextStyle(fontSize: 20, color: Colors.orange),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditProfilePage(
                              firstName: firstName,
                              lastName: lastName,
                              userName: userName,
                              spaceBodies: spaceBodies,
                            ),
                      ),
                    );
                    if (updated == true) {
                      // Refresh if needed
                    }
                  },
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => signOut(),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
