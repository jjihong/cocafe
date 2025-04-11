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
      ),
      debugShowCheckedModeBanner: false,
      title: 'cocafe',
      getPages: [
        GetPage(name: "/", page: () => Home()),
      ],
    );
  }
}
