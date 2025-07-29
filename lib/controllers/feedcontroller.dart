// lib/controllers/feed_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/postmodel.dart';

class FeedController extends GetxController {
  final RxList<PostModel> posts = <PostModel>[].obs;

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
      return PostModel.fromSnapshot(doc);
    }).toList();

    posts.assignAll(list);
  }

  Future<void> reload() async {
    await loadPosts();
    posts.refresh(); // 새로고침 시 다시 로드
  }
}