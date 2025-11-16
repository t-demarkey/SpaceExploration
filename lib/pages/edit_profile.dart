import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:space_exploration/space_body.dart'; // Import SpaceBody model

class EditProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String userName;
  final List<SpaceBody> spaceBodies; // Pass spaceBodies list

  const EditProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.spaceBodies, // Accept the list
  });

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? selectedProfilePhoto;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.firstName;
    _lastNameController.text = widget.lastName;
    _userNameController.text = widget.userName;
  }

  Future<void> _updateProfile() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('user').doc(user.uid).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'userName': _userNameController.text,
          if (selectedProfilePhoto != null)
            'profilePhoto': selectedProfilePhoto,
        });

        messenger.showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        navigator.pop(true);
      }
    } catch (e) {
      //print("Error updating profile: $e");
      messenger.showSnackBar(const SnackBar(content: Text('Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            Text('Select Profile Photo:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            // Display space body images in a row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.spaceBodies.map((body) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedProfilePhoto = body.imagePath; // Set selected image
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedProfilePhoto == body.imagePath
                              ? Colors.green // Green border for selected photo
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Image.asset(
                        body.imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
