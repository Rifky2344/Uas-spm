import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Secara default, tampilkan halaman login
  bool showLoginScreen = true;

  // Fungsi untuk beralih tampilan
  void toggleScreens() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen) {
      return LoginScreen(showSignUpScreen: toggleScreens);
    } else {
      return SignUpScreen(showLoginScreen: toggleScreens);
    }
  }
}
