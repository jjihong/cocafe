import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../screens/home.dart';

class AuthService {

  static Future<void> signInWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        var provider = OAuthProvider('oidc.cocafe');
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        var credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken,
        );

        final credentialUser =
        await FirebaseAuth.instance.signInWithCredential(credential);
        final user = credentialUser.user;

        if (user != null) {
          await handleUserAfterLogin(user); // ✅ Firestore 저장 처리
        }
      } catch (error) {
        print('카카오톡 로그인 실패: $error');
        if (error is PlatformException && error.code == 'CANCELED') return;

        try {
          var provider = OAuthProvider('oidc.cocafe');
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          var credential = provider.credential(
            idToken: token.idToken,
            accessToken: token.accessToken,
          );

          final credentialUser =
          await FirebaseAuth.instance.signInWithCredential(credential);
          final user = credentialUser.user;

          if (user != null) {
            await handleUserAfterLogin(user); // ✅ Firestore 저장 처리
          }
        } catch (error) {
          print('카카오계정 로그인 실패: $error');
        }
      }
    } else {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        var provider = OAuthProvider('oidc.cocafe');
        var credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken,
        );

        final credentialUser =
        await FirebaseAuth.instance.signInWithCredential(credential);
        final user = credentialUser.user;

        if (user != null) {
          await handleUserAfterLogin(user); // ✅ Firestore 저장 처리
        }
      } catch (error) {
        print('카카오계정 로그인 실패: $error');
      }
    }
  }

  static Future<void> handleUserAfterLogin(auth.User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'name': user.displayName ?? '익명',
        'town': null,
        'createdAt': FieldValue.serverTimestamp(),
      }); // ✅ 새 유저 저장
      print('✅ Firestore에 유저 정보 저장 완료');
    } else {
      print('ℹ️ 이미 가입된 유저');
    }

    // ✅ 로그인 성공 후 홈으로 이동
    Get.offAll(() => const Home());
  }
}