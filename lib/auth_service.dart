import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  // instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // sign user in
  Future<UserCredential> signInWithEmailandPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String userName,
  ) async {
    try {
      // sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // add new document for user in users collection if doesnt exist
      _fireStore.collection("user").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'userName': userName,
      }, SetOptions(merge: true));

      return userCredential; // return the userCredential
    } on FirebaseAuthException catch (e) {
      // catch errors
      throw Exception(e.code); // throw exception with error code
    }
  }

  //create a new user
  Future<UserCredential> signUpWithEmailandPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String userName,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // after creating user, create a new document for the user
      _fireStore.collection("user").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'userName': userName,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign user out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
