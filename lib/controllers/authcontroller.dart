import 'package:cocafe/controllers/postcontroller.dart';
import 'package:cocafe/controllers/towncontroller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/likeservice.dart';
import 'feedcontroller.dart';

class AuthController extends GetxController {
  // FirebaseAuth 상태 변화(stream)를 구독해 유저 객체를 갖고 있게 함
  final Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());
    super.onInit();
  } // onInit 끝

  // 편의 getter: uid가 없을 수도 있으니 nullable
  String? get uid => firebaseUser.value?.uid;

  // 로그아웃 메서드
  Future<void> signOut() async {

    await FirebaseAuth.instance.signOut();

    // 컨트롤러들 삭제
    Get.delete<FeedController>();
    Get.delete<PostController>();
    Get.delete<LikeService>();

    // TownController 초기화 (permanent라서 삭제 안됨)
    Get.find<TownController>().selectedTown.value = '';

    // 로그인 화면으로 이동하면서 모든 이전 화면 제거
    Get.offAllNamed('/');

  } // signOut 끝
} // AuthController 클래스 끝
