import 'package:cocafe/screens/map/index.dart';
import 'package:cocafe/screens/my/mypage.dart';
import 'package:flutter/material.dart';

import 'feed/index.dart';

final List<BottomNavigationBarItem> myTabs = <BottomNavigationBarItem>[
  const BottomNavigationBarItem(icon: Icon(Icons.feed), label: '동네'),
  const BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
  const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이'),
];

final List<Widget> myTabItems = [
  const FeedIndex(),
  const MapIndex(),
  const MyPageScreen()
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: myTabs,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: myTabItems,
      ),
    );
  }
}
