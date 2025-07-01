import 'package:cocafe/screens/map/index.dart';
import 'package:cocafe/screens/my/mypage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/feedcontroller.dart';
import '../services/likeservice.dart';
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
  void initState() {
    super.initState();

    // ✅ 필요한 컨트롤러들 미리 생성
    if (!Get.isRegistered<FeedController>()) {
      Get.put(FeedController());
    }
    if (!Get.isRegistered<LikeService>()) {
      Get.put(LikeService());
    }
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
