import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // ✅ 추가


class TownController extends GetxController {
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> filteredLocations = [];

  var selectedTown = ''.obs;

  Future<void> loadLocations() async {
    String jsonString = await rootBundle.loadString('asset/json/towns.json');
    locations = List<Map<String, dynamic>>.from(json.decode(jsonString));
    filteredLocations = []; // 초기엔 비워둠
  }

  void filterLocations(String query) {
    if (query.isEmpty) {
      filteredLocations = [];
    } else {
      final lowerQuery = query.toLowerCase().replaceAll(' ', '');
      // 중복을 제거하기 위해 Set을 사용
      final uniqueResults = <String>{};

      filteredLocations = locations.where((location) {
        final combined = "${location['시도']}${location['시군구']}${location['읍면동']}"
            .toLowerCase()
            .replaceAll(' ', '');

        // 중복된 값이 없다면 필터링된 리스트에 추가
        if (combined.contains(lowerQuery) && !uniqueResults.contains(combined)) {
          uniqueResults.add(combined); // 중복 값 추가 방지
          return true;
        }
        return false;
      }).toList();
    }
  }


  // void selectTown(Map<String, dynamic> location) {
  //   selectedTown.value =
  //       "${location['시도']} ${location['시군구']} ${location['읍면동']}".trim();
  // }

  // 앱 껏다키면 그 설정을 유지
  Future<void> saveSelectedTown(String townName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTown', townName);
    selectedTown.value = townName;
    print('✅ 저장 완료: $townName'); // 디버깅용 로그 추가
  }

  Future<void> loadSelectedTown() async {
    final prefs = await SharedPreferences.getInstance();
    selectedTown.value = prefs.getString('selectedTown') ?? '';
  }

  Future<void> setTownFromCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('📍 현재 위치: ${position.latitude}, ${position.longitude}');

      // ✅ Kakao REST API로 주소 정보 요청
      final townName = await fetchAddressFromLatLng(position.latitude, position.longitude);

      if (townName != null) {
        await saveSelectedTown(townName);
        Get.back();
        print('📍 현재 위치 동네 설정 완료: $townName');
      } else {
        Get.snackbar('알림', '현재 위치의 동네를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('❌ 위치 설정 실패: $e');
      Get.snackbar('오류', '현재 위치를 가져올 수 없습니다.');
    }
  }

  Future<String?> fetchAddressFromLatLng(double lat, double lng) async {
    final url = Uri.parse('https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=$lng&y=$lat');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'KakaoAK 7f91f980c97d305201065841b4be0025',
        'KA': 'sdk/flutter os/android lang/ko-KR device/emulator', // ✅ 형식 변경
      },
    );


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final documents = data['documents'];

      if (documents != null && documents.isNotEmpty) {
        final doc = documents.first;
        final sido = doc['region_1depth_name'];
        final sigungu = doc['region_2depth_name'];
        final eupmyeondong = doc['region_3depth_name'];
        print('🧭 카카오 주소: $sido $sigungu $eupmyeondong');
        return '$sido $sigungu $eupmyeondong';
      }
    } else {
      print('❌ 주소 조회 실패: ${response.body}');
    }
    return null;
  }
}