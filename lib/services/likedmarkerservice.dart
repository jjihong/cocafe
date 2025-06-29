import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';

import '../controllers/authcontroller.dart';

// 지도에 좋아요 리스트를 관리하는 목적
class LikedMarkerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NMarker> likedMarkers = <NMarker>[].obs;

  Future<LikedMarkerService> init() async {
    await loadLikedMarkers(); // 앱 시작 시 초기 로드
    return this;
  }

  // 리스트 갱신
  Future<void> loadLikedMarkers() async {
    final userId = Get.find<AuthController>().uid;
    if (userId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final likedPostIds = List<String>.from(userDoc['liked_posts'] ?? []);

      final newMarkers = <NMarker>[];

      for (final postId in likedPostIds) {
        final postDoc = await _firestore.collection('posts').doc(postId).get();
        final data = postDoc.data();
        if (data == null) continue;

        final lat = double.tryParse(data['lat'].toString());
        final lng = double.tryParse(data['lng'].toString());
        if (lat == null || lng == null) continue;

        final marker = NMarker(
          id: 'liked_$postId',
          position: NLatLng(lat, lng),
        );
        marker
            .setIcon(const NOverlayImage.fromAssetImage('asset/likeicon.png'));

        newMarkers.add(marker);
      }

      likedMarkers.assignAll(newMarkers);
      likedMarkers.refresh();
      print("🌀 likedMarkers 변경 감지 → 갱신 완료");
    } catch (e) {
      print("🔥 LikedMarkerService 에러: $e");
    }
  }
}
