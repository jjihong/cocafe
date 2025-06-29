import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// 현재 위치(펭귄) 누르면 나올 명언, 조언
final List<String> quotes = [
  "오늘도 수고했어. 충분히 잘하고 있어.",
  "할 수 있다. 넌 충분히 강해.",
  "작은 전진도 멈추지 않으면 큰 도약이 돼.",
  "피할 수 없으면 즐겨라 피즐!.",
  "while (지치지_않음) { 꿈 += 도전; }",
  "const 나 = 항상_최선을_다하는_사람;",
  'try {\n\t매일조금씩(성장);\n} catch (의심) {\n\tthrow "넌 충분히 잘하고 있어.";\n}',
  '''String[] today = {"열정", "끈기", "너"};\nSystem.out.println(Arrays.toString(today));''',
  '''for (int i = 0; i < 무한; i++) {\n\tif (버그 == 0) break;\n\t디버깅();\n}''',
];

// MapIndex관리할 컨트롤러
class MapController {
  // 네이버컨트롤러 관련 설정
  NaverMapController? _controller;
  NMarker? _currentLocationMarker; // 현재 위치 마커 추적용
  final List<NMarker> likedMarkersOnMap = []; // 지도 위에 표시된 좋아요 마커 추적

  void Function(String quote)? onMarkerTapCallback;
  void Function(String postId)? onLikedMarkerTapCallback; // ✅ 콜백 등록용

  void setController(NaverMapController controller) {
    _controller = controller;
  }

  // 현재 위치로 보내기.
  Future<void> moveToCurrentLocation() async {
    if (_controller == null) return;

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = NLatLng(position.latitude, position.longitude);

      await _controller!.updateCamera(
        NCameraUpdate.fromCameraPosition(
            NCameraPosition(target: latLng, zoom: 15)),
      );

      // 기존 현재위치 마커 삭제 후
      if (_currentLocationMarker != null) {
        await _controller!.deleteOverlay(_currentLocationMarker!.info);
      }

      // 새로운 마커 생성 및 저장
      final marker = NMarker(id: 'current_location', position: latLng);
      marker.setIcon(
          const NOverlayImage.fromAssetImage('asset/current_place.png'));
      marker.setOnTapListener((_) {
        final quote = quotes[Random().nextInt(quotes.length)];
        onMarkerTapCallback?.call(quote);
      });

      await _controller!.addOverlay(marker);
      _currentLocationMarker = marker; // ✅ 추적 갱신
    } catch (e) {
      print("🚨 현재 위치 이동 실패: $e");
    }
  }

  // 좋아요 마커 생성
  Future<void> addLikedMarkers(List<NMarker> markers) async {
    if (_controller == null) return;

    for (final marker in markers) {
      final markerId = marker.info.id;
      if (likedMarkersOnMap.any((m) => m.info.id == markerId)) {
        print("⚠️ 이미 존재하는 마커 건너뜀: $markerId");
        continue;
      }

      marker.setOnTapListener((_) {
        print('🔥 마커 클릭됨: $markerId');
        final postId = marker.info.id.replaceFirst('liked_', '');
        onLikedMarkerTapCallback?.call(postId);
      });

      try {
        await _controller!.addOverlay(marker);
        likedMarkersOnMap.add(marker);
      } catch (e) {
        print("❗마커 추가 실패: $markerId - $e");
      }
    }
  }

  // 좋아요 마커 제거
  Future<void> clearLikedMarkers() async {
    if (_controller == null) return;

    final markersToRemove = List<NMarker>.from(likedMarkersOnMap);

    for (final marker in markersToRemove) {
      try {
        await _controller!.deleteOverlay(marker.info);
      } catch (e) {
        print("❗삭제 실패 (무시됨): ${marker.info.id} - ${e.toString()}");
      }
    }

    likedMarkersOnMap.clear();
  }

  Future<bool> _handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
