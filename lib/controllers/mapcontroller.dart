import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// controller에서 view를 참조하지 않음.
// import '../screens/map/index.dart';

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

class MapController {
  NaverMapController? _controller;

  /// ✅ 외부에서 콜백 설정 가능하게 선언
  void Function(String quote)? onMarkerTapCallback;

  void setController(NaverMapController controller) {
    _controller = controller;
  }

  Future<void> moveToCurrentLocation() async {
    if (_controller == null) {
      print("🛑 NaverMapController가 아직 초기화되지 않았습니다.");
      return;
    }

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      print("🛑 위치 권한이 거부되었습니다.");
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final latLng = NLatLng(position.latitude, position.longitude);

      // 📌 카메라 이동
      await _controller!.updateCamera(
        NCameraUpdate.fromCameraPosition(
            NCameraPosition(target: latLng, zoom: 15)),
      );

      // 📌 기존 마커 제거 (중복 방지)
      await _controller!.clearOverlays(type: NOverlayType.marker);

      // 📌 마커 생성
      final marker = NMarker(id: 'current_location', position: latLng);

      // ✅ 이미지 설정
      marker.setIcon(NOverlayImage.fromAssetImage('asset/current_place.png'));

      marker.setOnTapListener((marker) {
        final quote = quotes[Random().nextInt(quotes.length)];
        onMarkerTapCallback?.call(quote);
      });

      // 📌 지도에 마커 추가
      await _controller!.addOverlay(marker);
    } catch (e) {
      print("🚨 현재 위치 이동/마커 표시 중 예외 발생: $e");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
