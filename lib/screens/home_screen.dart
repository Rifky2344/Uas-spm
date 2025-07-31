import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_post_screen.dart';
import 'post_detail_screen.dart';
import 'edit_post_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          'Asset/Fesnuk.png',
          fit: BoxFit.contain,
        ),
        title: const Text('Fesnuk'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.lightBlue[100],
        actions: [
          Row(
            children: [
              Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.black87,
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getPostsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Terjadi kesalahan'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = snapshot.data!.docs;
            if (posts.isEmpty) {
              return const Center(child: Text('Belum ada postingan.'));
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                var post = posts[index].data() as Map<String, dynamic>;
                String docId = posts[index].id;

                // --- LOGIKA YANG DIPERBAIKI ---
                bool isAuthor = false;
                if (currentUser != null) {
                  // Cek untuk postingan baru (berdasarkan UID)
                  bool isAuthorByUid =
                      post.containsKey('authorUid') &&
                      currentUser!.uid == post['authorUid'];
                  // Cek untuk postingan lama (berdasarkan email sebagai fallback)
                  bool isAuthorByEmail =
                      post.containsKey('author') &&
                      currentUser!.email == post['author'];

                  isAuthor = isAuthorByUid || isAuthorByEmail;
                }

                // Update the Card ListTile in ListView.builder
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                        post['authorProfilePicture'] ?? 'assets/pp/avatar1.jpg',
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostDetailScreen(post: post, docId: docId),
                        ),
                      );
                    },
                    title: Text(
                      post['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      "Oleh: ${post['authorUsername'] ?? post['author'] ?? 'Anonim'}",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAuthor) ...[
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPostScreen(
                                    post: post,
                                    docId: docId,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _firestoreService.deletePost(docId),
                          ),
                        ],
                        StreamBuilder<bool>(
                          stream: _firestoreService.getLikeStatus(
                              docId, currentUser?.uid ?? ''),
                          builder: (context, snapshot) {
                            final bool isLiked = snapshot.data ?? false;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: currentUser == null
                                      ? null
                                      : () => _firestoreService.toggleLike(
                                          docId, currentUser!.uid),
                                ),
                                Text(
                                  '${post['likeCount'] ?? 0}',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              },
              icon: const Icon(Icons.account_circle),
              label: const Text('Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkMode ? Colors.grey[700] : Colors.lightBlue[100],
                foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPostScreen()),
                );
              },
              backgroundColor:
                  isDarkMode ? Colors.grey[600] : Colors.lightBlue[200],
              child: const Icon(Icons.add, size: 32),
            ),
            ElevatedButton.icon(
              onPressed: () => _authService.signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkMode ? Colors.red[900] : Colors.red[100],
                foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
