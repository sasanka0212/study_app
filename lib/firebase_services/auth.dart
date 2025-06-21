import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/classes/user_data.dart';
import 'package:study_app/classes/user_properties.dart';
import 'package:study_app/firebase_services/database_methods.dart';
import 'package:study_app/view/auth/login.dart';
import 'package:study_app/view/user/menu/home_navigation.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getCurrentUser() async {
    return auth.currentUser;
  }

  Future<bool> collectionExits(String path) async {
    final snapShot = await firestore.collection(path).limit(1).get();
    return snapShot.docs.isEmpty;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn
        .signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential authCredential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication?.idToken,
      accessToken: googleSignInAuthentication?.accessToken,
    );

    final UserCredential result = await firebaseAuth.signInWithCredential(
      authCredential,
    );

    final User? user = result.user;

    bool isExist = await collectionExits('user_data');
    if (isExist) {
      // does not exists
      await firestore
          .collection('user_data')
          .doc(user!.uid)
          .set(UserProperties(id: user.uid).toMap());
    } else {
      final doc = await firestore.collection('user_data').doc(user!.uid).get();
      if(!doc.exists) {
        await firestore
          .collection('user_data')
          .doc(user.uid)
          .set(UserProperties(id: user.uid).toMap());
      }
    }

    Map<String, dynamic> userData = UserData(
      email: user.email!,
      name: user.displayName!,
      photoUrl: user.photoURL ?? "",
      id: user.uid,
    ).toMap();
    await DatabaseMethods().addUser(user.uid, userData);
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('username', user.displayName!);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeNavigation()),
    );
  }

  signOff(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LogIn()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      print(e);
    }
  }
}
