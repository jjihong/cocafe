import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import '../../controllers/mapcontroller.dart';
import '../../services/likedmarkerservice.dart';
import '../../widgets/buttons/categorybutton.dart';
import '../../widgets/modal/liked_marker_modal.dart';

class MapIndex extends StatefulWidget {
  const MapIndex({super.key});

  @override
  State<MapIndex> createState() => _MapIndexState();
}

class _MapIndexState extends State<MapIndex> {
  final mapController = MapController();

  final likedMarkerService = Get.find<LikedMarkerService>(); // 좋아요 서비스 불러오기
  List<String> selectedCategories = [];
  final List<NMarker> markers = [];
  bool _everRegistered = false; // 중복 방지 플래그 추가

  // 카테고리 버튼 활성화
  void toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('코딩 추천 장소')),
      body: Stack(
        children: [
          NaverMap(
              options: const NaverMapViewOptions(
                locationButtonEnable: false, // 기본 위치버튼 제거
                indoorEnable: false,
              ),
              onMapReady: (controller) async {
                mapController.setController(controller);
                mapController.onMarkerTapCallback = (quote) {
                  showMotivationalSnackBar(context, quote);
                };

                mapController.onLikedMarkerTapCallback = (postId) {
                  showLikedMarkerBottomSheet(context, postId); // 👈 여기가 핵심
                };

                await mapController.moveToCurrentLocation();
                await likedMarkerService.loadLikedMarkers(); // 데이터만 불러오기
                await mapController
                    .addLikedMarkers(likedMarkerService.likedMarkers);

                if (!_everRegistered) {
                  _everRegistered = true;

                  ever<List<NMarker>>(likedMarkerService.likedMarkers,
                      (markers) async {
                    await mapController.clearLikedMarkers();
                    await mapController.addLikedMarkers(markers);
                  });
                }
              }),

          /// 현재 위치로 이동 버튼
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: () async {
                await mapController.moveToCurrentLocation();
              },
              backgroundColor: Colors.white,
              heroTag: 'map_fab',
              child: const Icon(Icons.my_location),
            ),
          ),

          /// 상단 카테고리 메뉴
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CategoryButton(
                    icon: Icons.electric_bolt,
                    title: '코드 많은',
                    selected: selectedCategories.contains('코드 많은'),
                    onTap: () => toggleCategory('코드 많은'),
                  ),
                  const SizedBox(width: 8),
                  CategoryButton(
                    icon: Icons.looks_two_rounded,
                    title: '2층 이상',
                    selected: selectedCategories.contains('2층 이상'),
                    onTap: () => toggleCategory('2층 이상'),
                  ),
                  const SizedBox(width: 8),
                  CategoryButton(
                    icon: Icons.volume_mute,
                    title: '조용한',
                    selected: selectedCategories.contains('조용한'),
                    onTap: () => toggleCategory('조용한'),
                  ),
                  const SizedBox(width: 8),
                  CategoryButton(
                    icon: Icons.book,
                    title: '스터디룸',
                    selected: selectedCategories.contains('스터디룸'),
                    onTap: () => toggleCategory('스터디룸'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 현재 위치를 누르면 명언 리스트 중 하나가 스낵바로 뜸.
  void showMotivationalSnackBar(BuildContext context, String quote) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          quote,
          style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
          textAlign: TextAlign.left,
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

void showLikedMarkerBottomSheet(BuildContext context, String postId) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return LikedMarkerModal(postId: postId); // ✅ 위젯 사용
    },
  );
}
