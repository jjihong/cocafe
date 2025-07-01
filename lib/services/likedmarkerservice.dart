import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/authcontroller.dart';

// 마커와 포스트 데이터를 함께 저장하는 클래스
class MarkerWithData {
  final NMarker marker;
  final Map<String, dynamic> postData;

  MarkerWithData({required this.marker, required this.postData});
}

// 지도에 좋아요 리스트를 관리하는 목적
class LikedMarkerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NMarker> likedMarkers = <NMarker>[].obs; // 전체 마커
  final RxList<NMarker> filteredMarkers = <NMarker>[].obs; // 필터링된 마커
  final List<MarkerWithData> _allMarkersWithData = []; // 마커와 데이터를 함께 저장
  List<String> _currentFilter = []; // 현재 적용된 필터
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
    filteredMarkers.clear();
    _allMarkersWithData.clear();
    likedMarkers.refresh();
    filteredMarkers.refresh();
    print("🧹 모든 좋아요 마커 제거");
  }

  // 필터 적용 메서드
  void applyFilter(List<String> categories) {
    _currentFilter = categories;

    if (categories.isEmpty) {
      // 필터가 없으면 모든 마커 표시
      filteredMarkers.assignAll(likedMarkers);
    } else {
      // 카테고리 필터링 적용 (AND 조건: 선택된 모든 카테고리를 포함해야 함)
      final filtered = _allMarkersWithData.where((markerWithData) {
        final tags = List<String>.from(markerWithData.postData['tags'] ?? []);

        // 선택된 모든 카테고리가 포스트 태그에 포함되어 있어야 표시
        return categories.every((category) => tags.contains(category));
      }).map((markerWithData) => markerWithData.marker).toList();

      filteredMarkers.assignAll(filtered);
    }

    filteredMarkers.refresh();
    print("🔍 필터 적용 (AND 조건): $categories, 결과: ${filteredMarkers.length}개 마커");
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
      final newMarkersWithData = <MarkerWithData>[];

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
        newMarkersWithData.add(MarkerWithData(marker: marker, postData: data));
      }

      // 전체 마커 목록 업데이트
      likedMarkers.assignAll(newMarkers);
      _allMarkersWithData.clear();
      _allMarkersWithData.addAll(newMarkersWithData);

      // 현재 필터 다시 적용
      applyFilter(_currentFilter);

      likedMarkers.refresh();
      print("🌀 likedMarkers 변경 감지 → 갱신 완료 (사용자: $userId, 전체 마커 수: ${newMarkers.length})");
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