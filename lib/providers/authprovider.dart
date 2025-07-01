import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/towncontroller.dart';
import '../screens/home.dart';

class AuthService {
  static Future<void> signInWithKakao() async {
    try {
      OAuthToken token;

      // 카카오톡 설치 여부에 따른 로그인 방식 결정
      if (await isKakaoTalkInstalled()) {
        try {
          // 카카오톡 로그인 시도
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          print('카카오톡 로그인 실패: $error');

          // 사용자가 취소한 경우 함수 종료
          if (error is PlatformException && error.code == 'CANCELED') {
            return;
          }

          // 카카오톡 로그인 실패 시 카카오계정 로그인으로 대체
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // 카카오톡이 설치되지 않은 경우 바로 카카오계정 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      // Firebase 인증 처리
      await _processFirebaseAuth(token);

    } catch (error) {
      print('카카오 로그인 실패: $error');
      _handleLoginError(error);
    }
  }

  // Firebase 인증 처리 분리
  static Future<void> _processFirebaseAuth(OAuthToken token) async {
    var provider = auth.OAuthProvider('oidc.cocafe');
    var credential = provider.credential(
      idToken: token.idToken,
      accessToken: token.accessToken,
    );
    final credentialUser = await auth.FirebaseAuth.instance.signInWithCredential(credential);
    final user = credentialUser.user;
    if (user != null) {
      await handleUserAfterLogin(user);
    } else {
      throw Exception('Firebase 인증 실패: 사용자 정보를 가져올 수 없습니다.');
    }
  }

  // 로그인 에러 처리
  static void _handleLoginError(dynamic error) {
    String errorMessage = '로그인 중 오류가 발생했습니다.';

    if (error is PlatformException) {
      switch (error.code) {
        case 'CANCELED':
          return; // 사용자 취소는 메시지 표시 안함
        case 'NETWORK_ERROR':
          errorMessage = '네트워크 연결을 확인해주세요.';
          break;
        default:
          errorMessage = '로그인에 실패했습니다. 다시 시도해주세요.';
      }
    }

    // GetX 스낵바로 에러 메시지 표시
    Get.snackbar(
      '로그인 실패',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  static Future<void> handleUserAfterLogin(auth.User user) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await userRef.get();
      if (!doc.exists) {
        await userRef.set({
          'name': user.displayName ?? '익명',
          'town': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Firestore에 유저 정보 저장 완료');
      } else {
        print('ℹ️ 이미 가입된 유저');
      }

      // ✅ 동네 컨트롤러 재등록 (이전 기록 초기화 목적)
      if (Get.isRegistered<TownController>()) {
        Get.delete<TownController>();
      }
      Get.put(TownController()); // onInit → 자동 위치 설정

      // ✅ 홈으로 이동
      Get.offAll(() => const Home());

    } catch (error) {
      print('사용자 정보 저장 실패: $error');
      Get.snackbar(
        '알림',
        '로그인은 성공했지만 사용자 정보 저장에 실패했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );

      final townController = Get.find<TownController>();
      await townController.reinitialize(); // 새 로그인 유저 기준 재설정


      Get.offAll(() => const Home());
    }
  }

  static Future<void> deleteAccount() async {
    try {
      final user = auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인된 사용자가 없습니다.');

      // 🔁 재인증을 위해 카카오 토큰 재요청
      final token = await UserApi.instance.loginWithKakaoAccount();

      final provider = auth.OAuthProvider('oidc.cocafe');
      final credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      // 🔐 재인증 시도
      await user.reauthenticateWithCredential(credential);

      // 🔥 Firestore 유저 문서 삭제
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // 🔥 Firebase 계정 삭제
      await user.delete();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('✅ 회원탈퇴 완료');
    } catch (e) {
      print('❌ 회원탈퇴 실패: $e');
      rethrow;
    }
  }


}


