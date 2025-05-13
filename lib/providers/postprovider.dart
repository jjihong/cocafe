import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/authcontroller.dart';

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
    required List<String> imageUrls,
    String? region1,
    String? region2,
    String? region3,
    String? bcode,
  }) async {
    final now = DateTime.now();
    final userId = Get.find<AuthController>().uid;

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
      'photos': imageUrls,
      'like_count': 0,
      'region1': region1,
      'region2': region2,
      'region3': region3,
      'bcode': bcode,
    });
  }
}
