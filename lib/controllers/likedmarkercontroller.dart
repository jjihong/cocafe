import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/postmodel.dart';

/// ▸ 모달 하나당 컨트롤러 하나 ― postId 를 생성자에서 바로 받아서 fetch 까지 자동 실행
class LikedMarkerController extends GetxController {
  LikedMarkerController(this.postId);

  final String postId;
  final _firestore = FirebaseFirestore.instance;

  // 상태
  final isLoading = true.obs;
  final post       = Rxn<PostModel>();
  final errorMsg   = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchPost();              // 위젯 build 전에 바로 데이터 로드
  }

  Future<void> _fetchPost() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        post.value = PostModel.fromSnapshot(doc);
      } else {
        errorMsg.value = '게시글을 찾을 수 없습니다.';
      }
    } catch (e) {
      errorMsg.value = '불러오는 중 오류: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    post.value = null;
    errorMsg.value = '';
    isLoading.value = false;
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}
