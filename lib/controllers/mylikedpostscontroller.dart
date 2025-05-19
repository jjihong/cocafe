import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/postmodel.dart';

class MyLikedPostsController extends GetxController {
  List<PostModel> myLikedPosts = [];
  bool isLoading = false;

  Future<void> fetchMyLikedPosts() async {
    isLoading = true;
    update();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final likedPostIds = List<String>.from(userDoc.data()?['liked_posts'] ?? []);

    // Firestore의 whereIn은 최대 10개까지만 지원됨
    final limitedIds = likedPostIds.take(10).toList();

    if (limitedIds.isEmpty) {
      myLikedPosts = [];
      isLoading = false;
      update();
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('posts')
        .where(FieldPath.documentId, whereIn: limitedIds)
        .get();

    myLikedPosts = snap.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();

    isLoading = false;
    update();
  }


  @override
  void onInit() {
    fetchMyLikedPosts();
    super.onInit();
  }
}
