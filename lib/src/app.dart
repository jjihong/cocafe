import 'package:cocafe/screens/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/authcontroller.dart';
import '../screens/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>(); // AuthController 찾기
    return GetMaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.doHyeonTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // 앱바 배경 흰색
        ),

        // BottomNavigationBar 기본 스타일 (BottomNavigationBar 위젯 사용할 때)
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // 바텀 네비게이션 배경
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          elevation: 8,
        ),
      ),
      home: Obx(() {
        return authC.firebaseUser.value != null
            ? const Home()
            : const LoginScreen();
      }),
      debugShowCheckedModeBanner: false,
      title: 'cocafe',
      getPages: [
        GetPage(name: "/", page: () => LoginScreen()),
        GetPage(name: '/home', page: () => const Home()), // 수정: 홈 경로 추가
      ],
    );
  }
}
