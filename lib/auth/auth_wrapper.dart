import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import 'auth_gate.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Jika sedang proses memeriksa status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Jika pengguna sudah login (snapshot punya data)
          else if (snapshot.hasData) {
            return HomeScreen();
          }
          // Jika pengguna belum login (snapshot tidak punya data)
          else {
            return const AuthGate();
          }
        },
      ),
    );
  }
}
