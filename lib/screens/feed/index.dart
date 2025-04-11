import 'package:cocafe/screens/feed/town.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controllers/towncontroller.dart';

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
          // 글쓰기 버튼을 눌렀을 때의 동작 추가
          // 예를 들어, 글쓰기 페이지로 이동하거나 다이얼로그를 띄우는 등의 동작을 추가할 수 있음.
          // Get.to(() => const WritePostPage()); // 글쓰기 페이지로 이동하는 예시
        },
        child: const Icon(Icons.add, color: Colors.white,), // 플로팅 버튼 아이콘 (여기서는 '+' 아이콘)
        backgroundColor: Colors.black, // 플로팅 버튼의 배경색
        shape: const CircleBorder(), // 동그라미 모양을 확실히 설정
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
