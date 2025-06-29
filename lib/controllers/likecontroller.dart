import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../services/likedmarkerservice.dart';

// firebase의 좋아요 상태 관리 목적
class LikeController extends GetxController {
  int likeCount = 0;
  String postId = '';
  String userId = '';
  bool? originalLiked; // 최초 진입시 상태 기억
  bool isDirty = false; // 좋아요 눌렀는지 판별
  bool isLiked = false; // ui 변경을 위한 판별

  // 생성시 필요정보 세팅, 초기화
  void init({
    required String postId_,
    required String userId_,
    required bool initialLiked,
    required int initialCount,
  }) {
    postId = postId_;
    userId = userId_;
    isLiked = initialLiked;
    originalLiked = initialLiked;
    likeCount = initialCount;
    isDirty = false;
  }

  // 제거
  @override
  void dispose() {
    if (Get.isRegistered<LikeController>()) {
      Get.delete<LikeController>();
    }
    super.dispose();
  }

  // 클릭 시 화면에서 업데이트
  void toggleLike() {
    isLiked = !isLiked;
    likeCount += isLiked ? 1 : -1;
    isDirty = true;
    update();
  }

  // 변경된 부분 지도 동기화 표시
  Future<void> persistLike() async {
    // 변한게 없다 or 초기화 안되있다면 리턴
    if (!isDirty) return;
    if (postId.isEmpty || userId.isEmpty) return;

    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      if (isLiked && originalLiked == false) {
        // 좋아요 클릭
        await postRef.update({'like_count': FieldValue.increment(1)});
        await userRef.update({
          'liked_posts': FieldValue.arrayUnion([postId])
        });
      } else if (!isLiked && originalLiked == true) {
        // 좋아요 취소
        await postRef.update({'like_count': FieldValue.increment(-1)});
        await userRef.update({
          'liked_posts': FieldValue.arrayRemove([postId])
        });
      }

      try {
        final likedMarkerService = Get.find<LikedMarkerService>();
        await likedMarkerService.loadLikedMarkers();
        print('🌀 좋아요 변경 → likedMarkers 갱신 완료');
      } catch (e) {
        print('❗likedMarkers 갱신 실패: $e');
      }

      isDirty = false;
    } catch (e) {
      print('🔥 persistLikeWithoutMap 에러: $e');
    }
  }
}
