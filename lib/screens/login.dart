import 'package:flutter/material.dart';
import 'package:cocafe/providers/authprovider.dart'; // 또는 provider

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'co - cafe',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ), // Text (타이틀) 끝
              const SizedBox(height: 12), // SizedBox 끝
              Text(
                '서로 코딩 스팟을 공유해요!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ), // Text (부제목) 끝
              const SizedBox(height: 32), // SizedBox 끝
              GestureDetector(
                onTap: () {
                  AuthService.signInWithKakao();
                }, // onTap 끝
                child: Image.asset(
                  'asset/kakao_login_medium_wide.png',
                ),
              ),
              // GestureDetector 끝
            ],
          ), // Column 끝
        ), // Padding 끝
      ), // Center 끝
    ); // Scaffold 끝
  } // build 끝
} // LoginScreen 클래스 끝

