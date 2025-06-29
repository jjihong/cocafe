
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../controllers/authcontroller.dart';

class PostProvider {
  final CollectionReference postsRef =
      FirebaseFirestore.instance.collection('posts');

  final CollectionReference draftsRef =
  FirebaseFirestore.instance.collection('drafts');

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
    String? lat,
    String? lng,
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
      'lat' : lat,
      'lng' : lng,
    });
  }

  // 임시저장
  Future<void> saveDraft({
    required String title,
    required String shopName,
    required String address,
    required String content,
    String? recommendMenu,
    required List<String> tags,
    required List<String> imagePaths, // 업로드 전 XFile의 path만 저장
    String? region1,
    String? region2,
    String? region3,
    String? bcode,
    String? lat,
    String? lng,
  }) async {
    final now = DateTime.now();
    final userId = Get.find<AuthController>().uid;

    await draftsRef.doc(userId).set({
      'title': title,
      'shop_name': shopName,
      'address': address,
      'content': content,
      'recommend_menu': recommendMenu ?? '',
      'tags': tags,
      'image_paths': imagePaths,
      'region1': region1,
      'region2': region2,
      'region3': region3,
      'bcode': bcode,
      'saved_at': now,
      'lat':lat,
      'lng':lng,
    });
  }

  // ✅ 임시저장 불러오기
  Future<Map<String, dynamic>?> loadDraft() async {
    final userId = Get.find<AuthController>().uid;
    final snap = await draftsRef.doc(userId).get();
    return snap.exists ? snap.data() as Map<String, dynamic> : null;
  }

  // ✅ 임시저장 삭제
  Future<void> deleteDraft() async {
    final userId = Get.find<AuthController>().uid;
    await draftsRef.doc(userId).delete();
  }
}
