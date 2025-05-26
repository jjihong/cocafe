import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DetailController extends GetxController {
  bool isLoading = true;
  Map<String, dynamic>? post;
  Map<String, dynamic>? user;

  Future<void> fetchPost(String postId) async {
    isLoading = true;
    update(); // 상태 갱신

    // 게시글 불러오기
    final postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();
    post = postSnap.data();
    post!['id'] = postSnap.id;

    // 사용자 정보 불러오기 + uid 직접 추가
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(post?['user_id'])
        .get();
    user = Map<String, dynamic>.from(userSnap.data() ?? {});
    user!['uid'] = userSnap.id; // ✅ 명시적으로 넣기

    isLoading = false;
    update(); // 상태 갱신
  }
}
