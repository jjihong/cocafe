// controllers/liked_marker_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/postmodel.dart';

class LikedMarkerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 반응형 상태 변수들
  var isLoading = false.obs;
  var post = Rxn<PostModel>(); // Rxn은 nullable 반응형 변수
  var errorMessage = ''.obs;

  // 특정 게시글 가져오기
  Future<void> fetchPost(String postId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final doc = await _firestore.collection('posts').doc(postId).get();

      if (doc.exists) {
        post.value = PostModel.fromSnapshot(doc);
      } else {
        errorMessage.value = '게시글을 찾을 수 없습니다.';
        post.value = null;
      }
    } catch (e) {
      errorMessage.value = '게시글을 불러오는 중 오류가 발생했습니다: $e';
      post.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // 컨트롤러 초기화
  void clearPost() {
    post.value = null;
    errorMessage.value = '';
    isLoading.value = false;
  }

  @override
  void onClose() {
    clearPost();
    super.onClose();
  }
}