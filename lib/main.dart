import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:interview/home.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Scommesse',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              bodySmall: TextStyle(fontSize: 14, fontStyle: FontStyle.italic))),
      home: const HomePage(),
    );
  }
}
