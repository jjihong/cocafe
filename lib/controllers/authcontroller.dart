import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
  } // signOut 끝
} // AuthController 클래스 끝
