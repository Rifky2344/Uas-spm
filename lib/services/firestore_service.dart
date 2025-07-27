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

  Future<DocumentReference<Map<String, dynamic>>> addPost(
    String title,
    String content,
    String authorUsername,
    String authorUid,
  ) async {
    // Get user profile to get profile picture
    DocumentSnapshot userProfile = await getUserProfile(authorUid);
    String profilePicture = (userProfile.data() as Map<String, dynamic>)['profilePicture'] ?? 'assets/profile_pictures/avatar1.jpg';
    
    return _db.collection('posts').add({
      'title': title,
      'content': content,
      'authorUsername': authorUsername,
      'authorUid': authorUid,
      'authorProfilePicture': profilePicture,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePost(String docId, String title, String content) async {
    await _db.collection('posts').doc(docId).update({
      'title': title,
      'content': content,
    });
  }

  Future<void> deletePost(String docId) async {
    await _db.collection('posts').doc(docId).delete();
  }

  Future<void> addComment(
    String postId,
    String commentText,
    String authorUsername,
    String authorUid,
  ) async {
    await _db.collection('posts').doc(postId).collection('comments').add({
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

  Future<void> updateProfilePicture(String uid, String picturePath) async {
    // Update user profile
    await _db.collection('users').doc(uid).update({
      'profilePicture': picturePath,
    });

    // Update all existing posts by this user
    final posts = await _db
        .collection('posts')
        .where('authorUid', isEqualTo: uid)
        .get();
        
    final batch = _db.batch();
    for (var doc in posts.docs) {
      batch.update(doc.reference, {'authorProfilePicture': picturePath});
    }
    await batch.commit();
  }
}
