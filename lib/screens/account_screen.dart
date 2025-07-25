import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Akun Saya")),
      body: currentUser == null
          ? const Center(child: Text("Pengguna tidak ditemukan."))
          : FutureBuilder<DocumentSnapshot>(
              future: _firestoreService.getUserProfile(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Gagal memuat profil."));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ListTile untuk Username (tanpa tombol edit)
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Username"),
                      subtitle: Text(userData['username'] ?? 'Belum diatur'),
                    ),
                    // ListTile untuk Email
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text("Email"),
                      subtitle: Text(userData['email'] ?? 'Tidak diketahui'),
                    ),
                    const Divider(height: 32),
                    // ListTile untuk Ubah Password
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      leading: const Icon(Icons.lock_outline),
                      title: const Text("Ubah Password"),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    const SizedBox(height: 24),
                    // Tombol Logout
                    TextButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                      ),
                      onPressed: () async {
                        await _authService.signOut();
                        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
  
  // Fungsi untuk ubah password tidak berubah
  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ubah Password"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Password baru"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.trim().length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password minimal 6 karakter."), backgroundColor: Colors.red));
                return;
              }
              try {
                await currentUser!.updatePassword(passwordController.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password berhasil diubah."), backgroundColor: Colors.green));
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: Coba logout dan login kembali terlebih dahulu."), backgroundColor: Colors.red));
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}