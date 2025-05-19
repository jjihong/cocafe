import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cocafe/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:cocafe/providers/authprovider.dart'; // 또는 provider



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
                  AuthService.signInWithKakao();
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

