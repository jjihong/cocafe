import 'package:cocafe/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'feed/town.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'co - cafe',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ), // Text (타이틀) 끝
              SizedBox(height: 12), // SizedBox 끝
              Text(
                '서로 코딩 스팟을 공유해요!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ), // Text (부제목) 끝
              SizedBox(height: 32), // SizedBox 끝
              GestureDetector(
                onTap: () {
                  signInWithKakao();
                }, // onTap 끝
                child: Image.asset(
                  'asset/kakao_login_medium_wide.png',
                ),
              ), // GestureDetector 끝
            ],
          ), // Column 끝
        ), // Padding 끝
      ), // Center 끝
    ); // Scaffold 끝
  } // build 끝
} // LoginScreen 클래스 끝

Future<void> signInWithKakao() async {
  // 카카오 로그인 구현 예제

// 카카오톡 실행 가능 여부 확인
// 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
  if (await isKakaoTalkInstalled()) {
    try {
      var provider = OAuthProvider('oidc.cocafe');
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
      var credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );
      FirebaseAuth.instance.signInWithCredential(credential);
      print('카카오톡으로 로그인 성공');
      Get.offAll(() => const Home()); // 수정: 계정 로그인 성공 후 홈으로 이동
    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');

      // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
      // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
      if (error is PlatformException && error.code == 'CANCELED') {
        return;
      }
      // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
      try {
        var provider = OAuthProvider('oidc.cocafe');
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        var credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken,
        );
        FirebaseAuth.instance.signInWithCredential(credential);
        print('카카오계정으로 로그인 성공');
        Get.offAll(() => const Home()); // 수정: 계정 로그인 성공 후 홈으로 이동
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  } else {
    try {
      await UserApi.instance.loginWithKakaoAccount();
      print('카카오계정으로 로그인 성공');
      Get.offAll(() => const Home());
    } catch (error) {
      print('카카오계정으로 로그인 실패 $error');
    }
  }
}
