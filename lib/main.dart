import 'package:flutter/material.dart';
import 'package:frontend/screens/Welcome.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AppGestionCobros());
}

class AppGestionCobros extends StatelessWidget {
  const AppGestionCobros({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
