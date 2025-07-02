import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/authcontroller.dart';
import '../models/likedmarkerdata.dart';

class LikedMarkerService extends GetxService {
  final _fs = FirebaseFirestore.instance;

  /*  리스트 타입을 LikedMarkerData 로 전면 교체  */
  final likedMarkers    = <LikedMarkerData>[].obs;
  final filteredMarkers = <LikedMarkerData>[].obs;

  List<String> _currentFilter = [];
  String?      _currentUserId;

  /* ───────────────────────────────────────── init ── */
  Future<LikedMarkerService> init() async {
    await _load();                            // 앱 첫 구동 시

    /* 로그인 상태 변화 감시 → 자동 리로드 */
    ever<User?>(Get.find<AuthController>().firebaseUser, (u) {
      _onUserChanged(u?.uid);
    });

    return this;
  }

  /* ────────────────────────── public API ── */
  void applyFilter(List<String> cats) {
    _currentFilter = cats;

    filteredMarkers.assignAll(
      cats.isEmpty
          ? likedMarkers
          : likedMarkers.where(
            (d) => cats.every((c) => d.tags.contains(c)),
      ),
    );
  }

  Future<void> refresh() => _load();           // 외부 강제 새로고침용

  /* ────────────────────────── internal ── */
  void _onUserChanged(String? uid) {
    if (_currentUserId == uid) return;         // 변화 없음
    _currentUserId = uid;

    if (uid == null) {
      likedMarkers.clear();
      filteredMarkers.clear();
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final uid = Get.find<AuthController>().uid;
    if (uid == null) {
      likedMarkers.clear();
      filteredMarkers.clear();
      return;
    }

    try {
      final userDoc   = await _fs.collection('users').doc(uid).get();
      final postIds   = List<String>.from(userDoc['liked_posts'] ?? []);
      final results   = <LikedMarkerData>[];

      for (final pid in postIds) {
        final doc = await _fs.collection('posts').doc(pid).get();
        if (!doc.exists) continue;

        final m = doc.data()!;
        if (m['lat'] == null || m['lng'] == null) continue;

        results.add(LikedMarkerData.fromMap(pid, m));
      }

      likedMarkers.assignAll(results);
      applyFilter(_currentFilter);             // 현 필터 유지
      print('🌀 LikedMarkers loaded: ${results.length}');
    } catch (e) {
      print('🔥 LikedMarkerService: $e');
      likedMarkers.clear();
      filteredMarkers.clear();
    }
  }
}
