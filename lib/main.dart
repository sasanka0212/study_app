import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:study_app/firebase_services/firebase_options.dart';
import 'package:study_app/view/auth/login.dart';
import 'package:study_app/view/auth/sign_up.dart';
import 'package:study_app/view/user/menu/home_navigation.dart';
import 'package:study_app/view/user/pages/home.dart';
import 'package:study_app/view/user/pages/mcq_question.dart';
import 'package:study_app/view/admin/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickStudy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LogIn(),
    );
  }
}
