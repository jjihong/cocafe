import 'package:cocafe/screens/feed/post.dart';
import 'package:cocafe/screens/feed/town.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controllers/towncontroller.dart';
import '../../widgets/listitems/post_listitem.dart';

class FeedIndex extends StatefulWidget {
  const FeedIndex({super.key});

  @override
  State<FeedIndex> createState() => _FeedIndexState();
}

class _FeedIndexState extends State<FeedIndex> {
  final TownController _townController = Get.find<TownController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                _showPopupMenu(context);
              },
              child: Obx(() => Text(
                    _townController.selectedTown.isEmpty
                        ? '동네 선택 v'
                        : '${_townController.selectedTown.value} v',
                    style: const TextStyle(color: Colors.black),
                  )),
            );
          },
        ),

        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.search),
        //   ),
        // ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => Post());
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        // 플로팅 버튼 아이콘 (여기서는 '+' 아이콘)
        backgroundColor: Colors.black,
        // 플로팅 버튼의 배경색
        shape: const CircleBorder(), // 동그라미 모양을 확실히 설정
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          final post = dummyPosts[index];
          return PostListItem(
            thumbnailUrl: post.imageUrl,
            title: post.title,
            shopName: post.shopName,
            likeCount: post.likeCount,
          );
        },
      ),
    );
  }

  // 팝업 메뉴를 띄우는 함수
  void _showPopupMenu(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final double dx = position.dx + renderBox.size.width; // 타이틀 오른쪽 끝의 x 좌표
    final double dy = position.dy + renderBox.size.height; // 타이틀 아래의 y 좌표

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(dx, dy, dx, dy),
      items: [
        PopupMenuItem<String>(
          value: 'townSetting', // 값 추가
          child: Text('동네 설정'),
        ),
        const PopupMenuItem<String>(
          value: 'currentLocation',
          child: Text('현재 위치'),
        ),
      ],
    ).then((value) async {
      // 팝업 메뉴에서 선택된 항목에 대해 처리
      if (value == 'townSetting') {
        // GetX를 이용해 Town 페이지로 이동
        Get.to(() => const Town());
      } else if (value == 'currentLocation') {
        await _townController.setTownFromCurrentLocation(); // ⬅️ 이거 실행
      }
    });
  }
}

// 임시용 더미 데이터
class PostModel {
  final String title;
  final String shopName;
  final String imageUrl;
  final int likeCount;

  PostModel({
    required this.title,
    required this.shopName,
    required this.imageUrl,
    required this.likeCount,
  });
}

final List<PostModel> dummyPosts = [
  PostModel(
    title: '주5일~4시간(주말 포함) 21312짧게 근무!!',
    shopName: '인창동 · 알바',
    imageUrl: 'https://i.namu.wiki/i/MIcM4D9MLjTDkRanLrqMjs_7HS7HuaDB7o2Wq_Dz0Cih4ARtmyrfll5zFGqb56tPFEDo0fuSVsIVGGk9A3xOROteYKXUlzeUtrYa6jyGl7saElt-O8dE4QCNukIqQBsQNq44dsqek2EcviPQ-fNVEw.webp',
    likeCount: 18,
  ),
  // 추가 더미...
];

