import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/postmodel.dart';

class MyPostsController extends GetxController {
  List<PostModel> myPosts = [];
  bool isLoading = false;

  Future<void> fetchMyPosts() async {
    isLoading = true;
    update(); // ✅ 상태 갱신

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('posts')
        .where('user_id', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .get();

    myPosts = snap.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();
    isLoading = false;
    update();
  }

  @override
  void onInit() {
    fetchMyPosts();
    super.onInit();
  }
}
