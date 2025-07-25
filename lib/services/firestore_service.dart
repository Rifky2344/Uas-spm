import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FUNGSI POSTINGAN & KOMENTAR ---

  Stream<QuerySnapshot> getPostsStream() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addPost(
    String title,
    String content,
    String authorUsername,
    String authorUid,
  ) {
    return _db.collection('posts').add({
      'title': title,
      'content': content,
      'authorUsername': authorUsername,
      'authorUid': authorUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePost(String docId, String title, String content) {
    return _db.collection('posts').doc(docId).update({
      'title': title,
      'content': content,
    });
  }

  Future<void> deletePost(String docId) {
    return _db.collection('posts').doc(docId).delete();
  }

  Future<void> addComment(
    String postId,
    String commentText,
    String authorUsername,
    String authorUid,
  ) {
    return _db.collection('posts').doc(postId).collection('comments').add({
      'text': commentText,
      'authorUsername': authorUsername,
      'authorUid': authorUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // --- FUNGSI PROFIL PENGGUNA ---

  Future<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<bool> checkUsernameExists(String username) async {
    final result = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  // Fungsi updateUsername dan updateAuthorUsernameInPostsAndComments sudah dihapus.
}
