import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final _db = FirebaseFirestore.instance; // Firestore 인스턴스

  Future<void> updateLikeCount(String postId, int delta) {
    return _db.collection('posts')
        .doc(postId)
        .update({'like_count': FieldValue.increment(delta)});
  }

  Future<void> addUserLike(String uid, String postId) {
    return _db.collection('users')
        .doc(uid)
        .set({'liked_posts': FieldValue.arrayUnion([postId])}, SetOptions(merge: true));
  }

  Future<void> removeUserLike(String uid, String postId) {
    return _db.collection('users')
        .doc(uid)
        .set({'liked_posts': FieldValue.arrayRemove([postId])}, SetOptions(merge: true));
  }
}