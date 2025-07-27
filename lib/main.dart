import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';

void main() async {
  // Pastikan Flutter binding telah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'BlogApp',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: 
                themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          ),
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(), // Jadikan AuthWrapper sebagai halaman utama
        );
      },
    );
  }
}
