import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _authorUsername;
  bool _isLoadingUsername = true;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  void _fetchUsername() async {
    if (currentUser != null) {
      try {
        final userProfile = await _firestoreService.getUserProfile(
          currentUser!.uid,
        );
        if (userProfile.exists) {
          setState(() {
            _authorUsername =
                (userProfile.data() as Map<String, dynamic>)['username'];
          });
        }
      } catch (e) {
        // Handle error
      } finally {
        setState(() {
          _isLoadingUsername = false;
        });
      }
    } else {
      setState(() {
        _isLoadingUsername = false;
      });
    }
  }

  void _addPost() async {
    if (_titleController.text.isNotEmpty &&
        _authorUsername != null &&
        currentUser != null) {
      await _firestoreService.addPost(
        _titleController.text.trim(),
        _contentController.text.trim(),
        _authorUsername!,
        currentUser!.uid, // <-- Mengirim UID pengguna
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Postingan Baru')),
      body: _isLoadingUsername
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Konten',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addPost,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Publikasikan'),
                  ),
                ],
              ),
            ),
    );
  }
}
