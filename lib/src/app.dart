import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      debugShowCheckedModeBanner: false,
      title: 'cocafe',
      getPages: [
        GetPage(name: "/", page: () => Home()),
      ],
    );
  }
}
