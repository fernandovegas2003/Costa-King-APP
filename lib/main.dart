import 'package:flutter/material.dart';
import './views/loadingScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BlessHealth24',
      home: const SplashScreen(),
    );
  }
}
