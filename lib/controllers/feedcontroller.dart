// page에 피드 뿌려주기

// lib/controllers/feed_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/postmodel.dart';
// PostModel import
import 'dart:math';

class FeedController extends GetxController {
  final RxList<PostModel> posts = <PostModel>[].obs;

  String _randomAsset() {
    final assets = [
      'asset/codog.png',
      'asset/copeng.png',
      'asset/cocat.png',
    ];
    return assets[Random().nextInt(assets.length)]; // Random() 직접 호출
  }

  @override
  void onInit() {
    super.onInit();
    loadPosts(); // 최초 1회 수동 로드
  }

  Future<void> loadPosts() async {
    // 선택 동네 bcode
    final prefs = await SharedPreferences.getInstance();
    final selectedBcode = prefs.getString('selectedBcode');

    if (selectedBcode == null || selectedBcode.isEmpty) {
      posts.clear();
      posts.refresh();
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('posts')
        .where('bcode', isEqualTo: selectedBcode)
        .orderBy('created_at', descending: true)
        .get();

    final list = snap.docs.map((doc) {
      final model = PostModel.fromSnapshot(doc);
      if (model.photos.isEmpty) {
        return PostModel(
          id: model.id,
          title: model.title,
          shopName: model.shopName,
          address: model.address,
          content: model.content,
          recommendMenu: model.recommendMenu,
          tags: model.tags,
          photos: [_randomAsset()],
          likeCount: model.likeCount,
          userId: model.userId,
          lat: model.lat,
          lng: model.lng,
          createdAt: model.createdAt,
          updatedAt: model.updatedAt,
        );
      }
      return model;
    }).toList();

    posts.assignAll(list); // 스트림이 아니라 한 번에 할당
  }

  Future<void> reload() async {
    await loadPosts();
    posts.refresh(); // 새로고침 시 다시 로드
  }
}
