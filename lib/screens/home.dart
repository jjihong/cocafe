import 'package:cocafe/screens/map/index.dart';
import 'package:cocafe/screens/my/mypage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/feedcontroller.dart';
import '../services/likedmarkerservice.dart';
import '../services/likeservice.dart';
import 'feed/index.dart';

final List<BottomNavigationBarItem> myTabs = <BottomNavigationBarItem>[
  const BottomNavigationBarItem(icon: Icon(Icons.feed), label: '동네'),
  const BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
  const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이'),
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

    // ✅ 동기적으로 먼저 생성
    if (!Get.isRegistered<FeedController>()) {
      Get.put(FeedController());
    }
    if (!Get.isRegistered<LikeService>()) {
      Get.put(LikeService());
    }

    // ✅ LikedMarkerService만 async로 처리
    Future.microtask(() async {
      if (!Get.isRegistered<LikedMarkerService>()) {
        await Get.putAsync(() => LikedMarkerService().init());
      }
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
        children: const [
          FeedIndex(), // ✅ 이제 컨트롤러가 있는 상태에서 생성
          MapIndex(),
          MyPageScreen(),
        ],
      ),
    );
  }
}