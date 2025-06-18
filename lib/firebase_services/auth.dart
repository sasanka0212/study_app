import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/classes/user_data.dart';
import 'package:study_app/firebase_services/database_methods.dart';
import 'package:study_app/view/auth/login.dart';
import 'package:study_app/view/user/menu/home_navigation.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential authCredential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication?.idToken,
      accessToken: googleSignInAuthentication?.accessToken,
    );

    final UserCredential result =
        await firebaseAuth.signInWithCredential(authCredential);

    final User? user = result.user;
    Map<String, dynamic> userData = UserData(
      email: user!.email!,
      name: user.displayName!,
      photoUrl: user.photoURL ?? "",
      id: user.uid,
    ).toMap();
    await DatabaseMethods().addUser(user.uid, userData);
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('username', user.displayName!);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeNavigation(),
      ),
    );
  }

  signOff(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LogIn(),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
