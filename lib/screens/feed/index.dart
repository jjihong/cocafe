import 'package:cocafe/controllers/feedcontroller.dart';
import 'package:cocafe/screens/feed/post.dart';
import 'package:cocafe/screens/feed/town.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/postcontroller.dart';
import '../../controllers/towncontroller.dart';
import '../../widgets/listitems/post_listitem.dart';
import '../../widgets/popupmenus/resume_draft_dialog.dart';
import 'detail.dart';

class FeedIndex extends StatefulWidget {
  const FeedIndex({super.key});

  @override
  State<FeedIndex> createState() => _FeedIndexState();
}

class _FeedIndexState extends State<FeedIndex> with WidgetsBindingObserver { // ✅ 라이프사이클 감지를 위한 믹스인 추가
  final TownController _townController = Get.find<TownController>();
  final FeedController _feedController = Get.find<FeedController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ 옵저버 등록
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ 옵저버 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _feedController.reload(); // ✅ 화면 복귀 시 새로고침
    }
  }

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
        onPressed: () async {
          final controller = Get.put(PostController());
          final hasDraft = await controller.hasDraft();

          if (hasDraft) {
            await ResumeDraftDialog.show(
              context: context,
              onDiscardDraft: () async {
                await controller.postProvider.deleteDraft();
                controller.clearAll();
              },
            );
          } else {
            Get.to(() => Post());
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        heroTag: 'feed_fab',
        // 플로팅 버튼 아이콘 (여기서는 '+' 아이콘)
        backgroundColor: Colors.black,
        // 플로팅 버튼의 배경색
        shape: const CircleBorder(), // 동그라미 모양을 확실히 설정
      ),
      // ▶ body: Firestore 스트림 구독
      body: Obx(() {
        final posts = _feedController.posts;
        return RefreshIndicator(
          onRefresh: () async {
            await _feedController.reload(); // 새로고침 시 실행될 메서드
          },
          child: posts.isEmpty
              ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Text('게시글이 없습니다.'),
                ),
              )
            ],
          )
              : ListView.builder(
            padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () async {
                   await Get.to(() => PostDetail(postId: post.id));
                    _feedController.reload();
                  },
                  child: PostListItem(
                    thumbnailUrl: post.photos[0],
                    title: post.title,
                    shopName: post.shopName,
                    likeCount: post.likeCount,
                  ),
                ),
              );
            },
          ),
        );
      }),
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
        const PopupMenuItem<String>(
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
