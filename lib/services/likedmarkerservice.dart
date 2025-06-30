import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/authcontroller.dart';

// 지도에 좋아요 리스트를 관리하는 목적
class LikedMarkerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NMarker> likedMarkers = <NMarker>[].obs;
  String? _currentUserId; // 현재 사용자 ID 추적

  Future<LikedMarkerService> init() async {
    await loadLikedMarkers(); // 앱 시작 시 초기 로드

    // AuthController의 firebaseUser 변경을 감지
    final authController = Get.find<AuthController>();
    ever(authController.firebaseUser, (User? user) {
      final newUserId = user?.uid;
      print("🔄 사용자 ID 변경 감지: $_currentUserId -> $newUserId");
      onUserChanged(newUserId);
    });

    return this;
  }

  // 사용자 변경 시 호출되는 메서드
  void onUserChanged(String? newUserId) {
    if (_currentUserId != newUserId) {
      _currentUserId = newUserId;

      if (newUserId == null) {
        // 로그아웃 시 마커 전체 제거
        clearAllMarkers();
      } else {
        // 새 사용자로 로그인 시 마커 다시 로드
        loadLikedMarkers();
      }
    }
  }

  // 모든 마커 제거
  void clearAllMarkers() {
    likedMarkers.clear();
    likedMarkers.refresh();
    print("🧹 모든 좋아요 마커 제거");
  }

  // 리스트 갱신
  Future<void> loadLikedMarkers() async {
    final authController = Get.find<AuthController>();
    final userId = authController.uid;

    if (userId == null) {
      clearAllMarkers();
      return;
    }

    // 현재 사용자 ID 업데이트
    _currentUserId = userId;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        clearAllMarkers();
        return;
      }

      final likedPostIds = List<String>.from(userDoc.data()?['liked_posts'] ?? []);

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
        marker.setIcon(const NOverlayImage.fromAssetImage('asset/likeicon.png'));

        newMarkers.add(marker);
      }

      likedMarkers.assignAll(newMarkers);
      likedMarkers.refresh();
      print("🌀 likedMarkers 변경 감지 → 갱신 완료 (사용자: $userId, 마커 수: ${newMarkers.length})");
    } catch (e) {
      print("🔥 LikedMarkerService 에러: $e");
      clearAllMarkers();
    }
  }

  // 수동으로 마커 새로고침하는 메서드 (필요 시 사용)
  Future<void> refreshMarkers() async {
    print("🔄 수동 마커 새로고침 요청");
    await loadLikedMarkers();
  }
}