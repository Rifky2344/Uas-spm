import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../providers/theme_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final String docId;

  const PostDetailScreen({super.key, required this.post, required this.docId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _commentController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String? _authorUsername;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  void _fetchUsername() async {
    if (currentUser != null) {
      final userProfile = await _firestoreService.getUserProfile(
        currentUser!.uid,
      );
      if (userProfile.exists) {
        if (mounted) {
          setState(() {
            _authorUsername =
                (userProfile.data() as Map<String, dynamic>)['username'];
          });
        }
      }
    }
  }

  void _postComment() {
    if (_commentController.text.isNotEmpty &&
        _authorUsername != null &&
        currentUser != null) {
      _firestoreService.addComment(
        widget.docId,
        _commentController.text.trim(),
        _authorUsername!,
        currentUser!.uid, // <-- Mengirim UID saat berkomentar
      );
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    final Timestamp? timestamp = widget.post['timestamp'];
    final formattedDate = timestamp != null
        ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
        : "Tanggal tidak tersedia";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.lightBlue[100],
        title: Text(widget.post['title'] ?? 'Detail Postingan'),
      ),
      body: Container(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture and author info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30, // Bigger avatar
                          backgroundImage: AssetImage(
                            widget.post['authorProfilePicture'] ?? 'assets/pp/avatar1.jpg',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post['title'] ?? 'Tanpa Judul',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Oleh: ${widget.post['authorUsername'] ?? 'Anonim'} • $formattedDate",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      widget.post['content'] ?? 'Konten tidak tersedia.',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Komentar",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildCommentsList(),
                  ],
                ),
              ),
            ),
            _buildCommentInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getCommentsStream(widget.docId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((doc) {
            final comment = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(comment['text']),
                subtitle: Text(
                  "Oleh: ${comment['authorUsername'] ?? 'Anonim'}",
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 5,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Tulis komentar...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: (_authorUsername == null) ? null : _postComment,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
