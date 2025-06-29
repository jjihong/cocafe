import 'package:get/get.dart';
import '../services/likeservice.dart';

class LikeController extends GetxController {
  final LikeService _service = Get.find<LikeService>(); // 수정: 서비스 주입
  var likeCount = 0.obs;             // RxInt
  var isLiked = false.obs;           // RxBool
  String postId = '';
  String uid = '';

  void init({
    required String postId_,
    required String uid_,
    required bool initialLiked,
    required int initialCount,
  }) {
    postId = postId_;                // ) init()
    uid = uid_;                      // ) init()
    isLiked.value = initialLiked;    // ) init()
    likeCount.value = initialCount;  // ) init()
  } // ) init()

  Future<void> toggleLike() async {
    final delta = isLiked.value ? -1 : 1;      // 좋아요 토글 전 계산
    isLiked.value = !isLiked.value;            // UI 즉시 반영
    likeCount.value += delta;                  // 카운트 즉시 반영

    // 서버 반영
    await _service.updateLikeCount(postId, delta);                // ) updateLikeCount()
    if (delta > 0) {
      await _service.addUserLike(uid, postId);                    // ) addUserLike()
    } else {
      await _service.removeUserLike(uid, postId);                 // ) removeUserLike()
    }
  } // ) toggleLike()
} // ) class LikeController 끝