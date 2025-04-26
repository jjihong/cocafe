import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geolocator/geolocator.dart';

class MapController {
  KakaoMapController? _controller;

  void setController(KakaoMapController controller) {
    _controller = controller;
  }

  Future<void> moveToCurrentLocation() async {
    if (_controller == null) {
      print("🛑 KakaoMapController가 아직 초기화되지 않았습니다.");
      return;
    }

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      print("🛑 위치 권한이 거부되었습니다.");
      return;
    }


    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final double lat = position.latitude;
      final double lng = position.longitude;
      print("📍 현재 위치: $lat, $lng");

      await _controller!.setCenter(LatLng(lat, lng));
    } catch (e) {
      print("🚨 현재 위치 이동 중 예외 발생: $e");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("🛑 위치 서비스가 비활성화되어 있어요.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print("🛑 위치 권한이 영구적으로 거부됨.");
      return false;
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<LatLng> getCenter() async {
    if (_controller == null) {
      throw Exception('KakaoMapController is not initialized');
    }
    return await _controller!.getCenter();
  }
}
