import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';

import '../../controllers/mapcontroller.dart';
import '../../models/likedmarkerdata.dart';
import '../../services/likedmarkerservice.dart';
import '../../widgets/common/buttons/categorybutton.dart';
import '../../widgets/common/modal/liked_marker_modal.dart';

class MapIndex extends StatefulWidget {
  const MapIndex({super.key});
  @override
  State<MapIndex> createState() => _MapIndexState();
}

class _MapIndexState extends State<MapIndex> {
  final mapCtl   = MapController();
  final likeSvc  = Get.find<LikedMarkerService>();

  List<String> selected = [];

  @override
  void initState() {
    super.initState();
    mapCtl.onPenguinTap  = (q) => _showSnack(q);
    mapCtl.onLikedTap    = (id) => _openModal(id);
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
            await likeSvc.refresh();                       // 첫 로드
            await mapCtl.syncLikedMarkers(likeSvc.filteredMarkers);

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
      backgroundColor: Colors.black87, duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
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
}
