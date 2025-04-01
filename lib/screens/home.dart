import 'package:flutter/material.dart';

final List<BottomNavigationBarItem> myTabs = <BottomNavigationBarItem>[
  BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: '홈'),
  BottomNavigationBarItem(icon: Icon(Icons.feed), label: '동네'),
  BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline_rounded), label: '채팅'),
  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이'),
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('안녕'),
    );
  }
}