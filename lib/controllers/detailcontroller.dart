import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

/// 글 화면
class DetailController extends GetxController {
  // 로딩 중 판별
  bool isLoading = true;

  // _를 붙이면 private
  Map<String, dynamic>? _post;
  Map<String, dynamic>? _user;

  // getter 설정
  Map<String, dynamic>? get post => _post;
  Map<String, dynamic>? get user => _user;
  List<String> get photos => List<String>.from(_post?['photos'] ?? []);


  /// 선택한 글 ID를 받아오기
  Future<void> fetchPost(String postId) async {
    isLoading = true;
    update(); // 상태 갱신

    /// 게시글 불러오기 + postid 직접추가
    final postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();
    _post = postSnap.data();
    post!['id'] = postSnap.id;

    /// 사용자 정보 불러오기 + uid 직접 추가
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(post?['user_id'])
        .get();
    _user = Map<String, dynamic>.from(userSnap.data() ?? {});
    user!['uid'] = userSnap.id;

    // 로딩 끝으로 변경
    isLoading = false;

    update(); // 상태 갱신
  }
}
