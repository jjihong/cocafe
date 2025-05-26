import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/postmodel.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/postmodel.dart';

class MyPostsController extends GetxController {
  var myPosts = <PostModel>[].obs;
  var isLoading = false;

  Future<void> fetchPosts(String uid) async {
    isLoading = true;
    update();

    // Firestore에서 uid 기준으로 게시글 가져오기
    final snap = await FirebaseFirestore.instance
        .collection('posts')
        .where('user_id', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .get();

    myPosts.value = snap.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();
    isLoading = false;
    update();
  }
}
