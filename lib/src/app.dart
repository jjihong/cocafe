import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      title: 'CoCa(Coding Cafe)',
      getPages: [
        GetPage(name:"/", page: ()=> Home()),
      ],
    );
  }
}