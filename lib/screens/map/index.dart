import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../controllers/mapcontroller.dart';
import '../../widgets/buttons/categorybutton.dart';

class MapIndex extends StatefulWidget {
  const MapIndex({super.key});

  @override
  State<MapIndex> createState() => _MapIndexState();
}

class _MapIndexState extends State<MapIndex> {
  final mapController = MapController();
  List<String> selectedCategories = [];


  @override
  void initState() {
    super.initState();
    // 위치 권한 요청을 먼저 함
    Future.delayed(Duration.zero, () async {
      await mapController.moveToCurrentLocation(); // 위치 먼저 가져오기
    });
  }

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
          KakaoMap(
            onMapCreated: (controller) {
              mapController.setController(controller);
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await mapController.moveToCurrentLocation();
              });
            },
            onMapTap: (latLng) {
              debugPrint('[DEBUG] 지도 탭: ${latLng.toString()}');
            },
          ),

          /// 📍 현재 위치로 이동 버튼
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'current_location_btn',
              onPressed: () async {
                await mapController.moveToCurrentLocation();
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),

          // 상단 메뉴바
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
                    onTap: () {
                      toggleCategory('코드 많은');
                    },
                  ),
                  const SizedBox(width: 8),
                  CategoryButton(
                      icon: Icons.looks_two_rounded,
                      title: '2층 이상',
                      selected: selectedCategories.contains('2층 이상'),
                      onTap: () {
                        toggleCategory('2층 이상');
                      },
                  ),
                  const SizedBox(width: 8),
                  CategoryButton(
                    icon: Icons.volume_mute,
                    title: '조용한',
                    selected: selectedCategories.contains('조용한'),
                    onTap: () {
                      toggleCategory('조용한');
                    },
                  ),
                  const SizedBox(width: 8),
                  CategoryButton(
                    icon: Icons.book,
                    title: '스터디룸',
                    selected: selectedCategories.contains('스터디룸'),
                    onTap: () {
                      toggleCategory('스터디룸');
                    },
                  ),
                ],
              ), // ListView
            ), // Container (카테고리 버튼)
          ),
        ],
      ),
    );
  }
}
