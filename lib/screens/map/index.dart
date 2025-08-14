import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';

import '../../controllers/mapcontroller.dart';
import '../../models/likedmarkerdata.dart';
import '../../services/likedmarkerservice.dart';
import '../../widgets/common/buttons/categorybutton.dart';
import '../../widgets/common/modal/liked_marker_modal.dart';
import '../../widgets/common/popup/recommend_popup.dart';
import '../../providers/cafeprovider.dart';
import '../../models/cafemodel.dart';

class MapIndex extends StatefulWidget {
  const MapIndex({super.key});
  @override
  State<MapIndex> createState() => _MapIndexState();
}

class _MapIndexState extends State<MapIndex> {
  final mapCtl      = MapController();
  final likeSvc     = Get.find<LikedMarkerService>();
  final cafeProvider = CafeProvider();           // API 호출용

  List<String> selected = [];
  List<CafeModel> cafes = [];                   // 카페 데이터 저장
  bool isLoadingCafes = false;                  // 로딩 상태
  bool isCafeMarkersVisible = true;             // 추천카페 마커 표시 여부

  @override
  void initState() {
    super.initState();
    mapCtl.onPenguinTap  = (q) => _showSnack(q);
    mapCtl.onLikedTap    = (id) => _openModal(id);
    mapCtl.onCafeTap     = (cafeId) => _showCafeInfo(cafeId);  // 카페 마커 탭
  }

  /* ───────────────────────── UI ── */

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('코딩 추천 장소')),
      body : Stack(children: [
        NaverMap(
          options  : const NaverMapViewOptions(indoorEnable: false),
          onMapReady: (c) async {
            mapCtl.attach(c);
            await mapCtl.moveToMe();
            
            // 기존 좋아요 마커 로드
            await likeSvc.refresh();
            await mapCtl.syncLikedMarkers(likeSvc.filteredMarkers);

            // 카페 API 데이터 로드 및 마커 표시
            await _loadCafes();

            /* 리액티브 감시 – 한 번만 */
            ever<List<LikedMarkerData>>(likeSvc.filteredMarkers,
                  (d) => mapCtl.syncLikedMarkers(d),
            );
          },
        ),

        /* 현재 위치 버튼 */
        Positioned(
          bottom: 16, left: 16,
          child: FloatingActionButton(
            heroTag: 'me_btn',
            backgroundColor: Colors.white,
            onPressed: () => mapCtl.moveToMe(),
            child: const Icon(Icons.my_location),
          ),
        ),

        /* 추천카페 토글 버튼 */
        Positioned(
          bottom: 16, right: 16,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: isCafeMarkersVisible ? Colors.orange : Colors.grey[600],
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: isLoadingCafes ? null : _toggleCafeMarkers,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.coffee,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCafeMarkersVisible ? '추천카페 ON' : '추천카페 OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isLoadingCafes) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        /* 카테고리 메뉴 */
        _buildFilterBar(),
      ]),
    );
  }

  Widget _buildFilterBar() {
    Widget btn(String t, IconData i) => CategoryButton(
      icon: i,
      title: t,
      selected: selected.contains(t),
      onTap: () {
        setState(() =>
        selected.contains(t) ? selected.remove(t) : selected.add(t));
        likeSvc.applyFilter(selected);
      },
    );

    return Positioned(
      top: 10, left: 0, right: 0,
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            btn('코드 많은', Icons.electric_bolt),
            const SizedBox(width: 8),
            btn('2층 이상', Icons.looks_two_rounded),
            const SizedBox(width: 8),
            btn('조용한', Icons.volume_mute),
            const SizedBox(width: 8),
            btn('스터디룸', Icons.book),
          ],
        ),
      ),
    );
  }

  /* ───────────────────────── helpers ── */

  void _showSnack(String q) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content : Text(q, style: const TextStyle(fontFamily: 'monospace')),
      backgroundColor: Colors.black87, 
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(
        bottom: 80, // 하단에서 80px 위로 올림 (버튼들 위)
        left: 16,
        right: 16,
      ),
    ),
  );

  Future<void> _openModal(String postId) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => LikedMarkerModal(postId: postId),
  );

  /* ─────────────────────── cafe functions ── */

  /// 카페 데이터를 API에서 불러와서 지도에 마커로 표시
  Future<void> _loadCafes() async {
    if (isLoadingCafes) return;
    
    setState(() => isLoadingCafes = true);
    
    try {
      // API에서 카페 데이터 가져오기
      final loadedCafes = await cafeProvider.fetchAllCafes();
      
      setState(() {
        cafes = loadedCafes;
      });
      
      // 지도에 카페 마커 동기화 (토글 상태에 따라)
      if (isCafeMarkersVisible) {
        await mapCtl.syncCafeMarkers(cafes);
        _showSnack('카페 ${cafes.length}개를 지도에 표시했습니다');
      } else {
        await mapCtl.clearCafeMarkers();
        _showSnack('카페 마커를 숨겼습니다');
      }
      
    } catch (e) {
      print('카페 로드 실패: $e');
      _showSnack('카페 정보를 불러오는데 실패했습니다');
      
    } finally {
      setState(() => isLoadingCafes = false);
    }
  }

  /// 카페 마커를 탭했을 때 호출되는 함수
  void _showCafeInfo(int cafeId) {
    // 카페 ID로 상세 정보 찾기
    final cafe = cafes.firstWhereOrNull((c) => c.id == cafeId);
    
    if (cafe != null) {
      _showCafePopup(cafe);
    } else {
      _showSnack('카페 정보를 찾을 수 없습니다 (ID: $cafeId)');
    }
  }

  /// 카페 추천 팝업 표시
  Future<void> _showCafePopup(CafeModel cafe) => showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: RecommendPopup(cafe: cafe),
    ),
  );

  /// 추천카페 마커 표시/숨김 토글
  Future<void> _toggleCafeMarkers() async {
    setState(() {
      isCafeMarkersVisible = !isCafeMarkersVisible;
    });

    if (isCafeMarkersVisible) {
      // ON: 항상 최신 데이터를 API에서 가져와서 표시
      await _loadCafes();
    } else {
      // OFF: 마커 숨김
      await mapCtl.clearCafeMarkers();
      _showSnack('추천카페 마커를 숨겼습니다');
    }
  }
}
