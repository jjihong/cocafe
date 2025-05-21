import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapController {
  NaverMapController? _controller;

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
      marker.setIcon(
          NOverlayImage.fromAssetImage('asset/current_place.png'));

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
