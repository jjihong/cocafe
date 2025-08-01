// controllers/detailcontroller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../controllers/authcontroller.dart'; // 수정: AuthController import 추가

/// 글 화면
class DetailController extends GetxController {
  // 로딩 중 판별
  bool isLoading = true;

  Map<String, dynamic>? _post;
  Map<String, dynamic>? _user;

  // 수정: 현재 로그인한 사용자의 liked_posts 저장 필드 추가
  List<String> _currentUserLikedPosts = [];
  List<String> get currentUserLikedPosts => _currentUserLikedPosts;

  // 추천 글 목록
  List<Map<String, dynamic>> _recommendedPosts = [];
  List<Map<String, dynamic>> get recommendedPosts => _recommendedPosts;

  // 기존 getter
  Map<String, dynamic>? get post => _post;
  Map<String, dynamic>? get user => _user;
  List<String> get photos => List<String>.from(_post?['photos'] ?? []);

  /// 선택한 글 ID를 받아오기
  Future<void> fetchPost(String postId) async {
    isLoading = true;
    update();

    // 게시글 불러오기 + postid 직접추가
    final postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();
    _post = postSnap.data();
    _post!['id'] = postSnap.id;

    // 작성자 정보 불러오기 + uid 직접 추가
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(_post?['user_id'])
        .get();
    _user = Map<String, dynamic>.from(userSnap.data() ?? {});
    _user!['uid'] = userSnap.id;

    // 수정: 현재 로그인한 사용자의 liked_posts 불러오기
    await fetchCurrentUserLikes();

    // 추천 글 로딩
    await fetchRecommendedPosts();

    isLoading = false;
    update();
  }

  /// 수정: AuthController로부터 uid 가져와서 liked_posts 배열 불러오기
  Future<void> fetchCurrentUserLikes() async {
    final authC = Get.find<AuthController>();
    final currentUid = authC.uid;
    if (currentUid == null) {
      _currentUserLikedPosts = [];
      return;
    }
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .get();
    final data = snap.data();
    _currentUserLikedPosts = List<String>.from(data?['liked_posts'] ?? []);
  }

  bool get isMyPost {
    final authC = Get.find<AuthController>();
    return _post?['user_id'] == authC.uid;
  }
  
  Future<void> deletePost() async {
    final postId = _post?['id'];
    if (postId == null) return;
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  /// 같은 동네(bcode) 다른 글 4개 가져오기
  Future<void> fetchRecommendedPosts() async {
    final currentBcode = _post?['bcode'];
    final currentPostId = _post?['id'];
    
    if (currentBcode == null || currentPostId == null) {
      _recommendedPosts = [];
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('posts')
          .where('bcode', isEqualTo: currentBcode)
          .orderBy('created_at', descending: true)
          .limit(10) // 여분으로 더 가져와서 현재 글 제외
          .get();

      final posts = query.docs
          .where((doc) => doc.id != currentPostId) // 현재 글 제외
          .take(4) // 4개만 선택
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .toList();

      _recommendedPosts = posts;
    } catch (e) {
      print('🔥 추천 글 로딩 실패: $e');
      _recommendedPosts = [];
    }
  }
}
