import 'dart:math';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

import '../models/likedmarkerdata.dart';

const _quotes = [
  '오늘도 수고했어. 충분히 잘하고 있어.',
  '할 수 있다. 넌 충분히 강해.',
  '작은 전진도 멈추지 않으면 큰 도약이 돼.',
  '피할 수 없으면 즐겨라 피즐!.',
  'while (지치지_않음) { 꿈 += 도전; }',
  'const 나 = 항상_최선을_다하는_사람;',
  'try { 매일조금씩(성장); } catch (e) { throw "넌 충분히 잘하고 있어."; }',
];

class MapController {
  NaverMapController? _naver;
  NMarker? _me;                               // 펭귄 마커
  final _likedOnMap = <NMarker>[];            // 현재 지도에 올라간 좋아요
  bool _isSyncing = false;                    // 동기화 중복 방지

  void Function(String)?   onPenguinTap;
  void Function(String)?   onLikedTap;        // postId 돌려줌

  /* ────────────────────────────── basic ── */
  void attach(NaverMapController c) {
    _naver = c;
    _likedOnMap.clear();                      // textureId 바뀜
  }

  /* ─────────────────────── current loc ── */
  Future<void> moveToMe() async {
    if (_naver == null) return;
    if (!await _locGranted()) return;

    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final latLng = NLatLng(p.latitude, p.longitude);

    await _naver!.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(target: latLng, zoom: 15),
      ),
    );

    if (_me != null) await _naver!.deleteOverlay(_me!.info);

    _me = NMarker(id: 'current_me', position: latLng)
      ..setIcon(const NOverlayImage.fromAssetImage('asset/current_place.png'))
      ..setOnTapListener((_) {
        onPenguinTap?.call(_quotes[Random().nextInt(_quotes.length)]);
      });

    await _naver!.addOverlay(_me!);
  }

  /* ─────────────────────── liked markers ── */

  /// datas 전체와 지도 상태를 '동기화'한다.
  Future<void> syncLikedMarkers(List<LikedMarkerData> datas) async {
    if (_naver == null || _isSyncing) return;
    _isSyncing = true;

    final wantIds = datas.map((d) => 'liked_${d.postId}').toSet();

    /* 1) 빠진 것 제거 - 개별적으로 안전하게 처리 */
    final toRemove = _likedOnMap.where((m) => !wantIds.contains(m.info.id)).toList();
    for (final marker in toRemove) {
      try {
        await _naver!.deleteOverlay(marker.info);
        _likedOnMap.remove(marker);
      } catch (e) {
        print('❗ deleteOverlay 실패: ${marker.info.id} - $e');
        // 실패해도 리스트에서는 제거 (이미 삭제된 상태일 수 있음)
        _likedOnMap.remove(marker);
      }
    }

    /* 2) 새로 필요한 것 추가 */
    for (final d in datas) {
      final id = 'liked_${d.postId}';
      if (_likedOnMap.any((m) => m.info.id == id)) continue;

      final m = NMarker(
        id: id,
        position: NLatLng(d.lat, d.lng),
      )
        ..setIcon(const NOverlayImage.fromAssetImage('asset/likeicon.png'))
        ..setOnTapListener((_) => onLikedTap?.call(d.postId));

      try {
        await _naver!.addOverlay(m);
        _likedOnMap.add(m);
      } catch (e) {
        print('❗ addOverlay 실패: $id - $e');
      }
    }
    
    _isSyncing = false;
  }

  /* ───────────────────────── util ── */
  Future<bool> _locGranted() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }
}
