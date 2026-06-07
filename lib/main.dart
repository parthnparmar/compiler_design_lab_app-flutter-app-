import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const CompilerLabApp());

class CompilerLabApp extends StatelessWidget {
  const CompilerLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compiler Design Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
