import 'package:cloud_firestore/cloud_firestore.dart';

class PostProvider {
  final CollectionReference postsRef =
  FirebaseFirestore.instance.collection('posts');

  Future<void> uploadPost({
    required String title,
    required String shopName,
    required String address,
    required String content,
    String? recommendMenu,
    required List<String> tags,
    required List<String> imageUrls,  // 여러 개 URL
    String userId = "test01",
  }) async {
    final now = DateTime.now();

    // ① 게시글 문서 먼저 추가
    final docRef = await postsRef.add({
      'title': title,
      'shop_name': shopName,
      'address': address,
      'content': content,
      'recommend_menu': recommendMenu ?? '',
      'tags': tags,
      'created_at': now,
      'updated_at': now,
      'user_id': userId,
      'photos' : imageUrls,
      'like_count': 0,
    });

  }
}
