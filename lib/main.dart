import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jolly Podcast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003334),
          primary: const Color(0xFF003334),
          secondary: const Color(0xFFA3CB43),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
