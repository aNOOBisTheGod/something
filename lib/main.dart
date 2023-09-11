import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:interview/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const InterviewApp());
}

class InterviewApp extends StatelessWidget {
  const InterviewApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
