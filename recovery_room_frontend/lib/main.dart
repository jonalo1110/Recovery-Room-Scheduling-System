import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(ThePitGymApp());
}

class ThePitGymApp extends StatelessWidget {
  const ThePitGymApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Color(0xFF4A6741),
        fontFamily: 'Inter',
      ),
      home: MainScreen(),
    );
  }
}