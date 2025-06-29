import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'feedcontroller.dart'; // ✅ 추가

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
        if (combined.contains(lowerQuery) &&
            !uniqueResults.contains(combined)) {
          uniqueResults.add(combined); // 중복 값 추가 방지
          return true;
        }
        return false;
      }).toList();
    }
  }

  Future<void> saveSelectedTown(Map<String, dynamic> location) async {
    final townName =
        "${location['시도']} ${location['시군구']} ${location['읍면동']}".trim();
    final bcode = location['코드'].toString(); // ✅ 코드 가져오기

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTown', townName);
    await prefs.setString('selectedBcode', bcode); // ✅ bcode 저장
    selectedTown.value = townName;

    print('✅ 동네 저장 완료: $townName / $bcode');

    final feedController = Get.find<FeedController>();
    await feedController.reload();
  }

  Future<void> loadSelectedTown() async {
    final prefs = await SharedPreferences.getInstance();
    selectedTown.value = prefs.getString('selectedTown') ?? '';
  }

  Future<void> setTownFromCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('📍 현재 위치: ${position.latitude}, ${position.longitude}');

      final locationData =
          await fetchAddressFromLatLng(position.latitude, position.longitude);

      if (locationData != null) {
        final townName = locationData['townName']!;
        final bcode = locationData['bcode']!;
        await _saveTownAndBcode(townName, bcode); // ✅ 따로 저장 함수로 분리해도 좋음
        Get.back();
        print('📍 현재 위치 동네 설정 완료: $townName / $bcode');
      } else {
        Get.snackbar('알림', '현재 위치의 동네를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('❌ 위치 설정 실패: $e');
      Get.snackbar('오류', '현재 위치를 가져올 수 없습니다.');
    }
  }

  Future<Map<String, String>?> fetchAddressFromLatLng(
      double lat, double lng) async {
    final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=$lng&y=$lat');

    final response = await http.get(
      url,
      headers: {
        'Authorization': dotenv.get('KAKAO_REST_API_KEY'),
        'KA': 'sdk/flutter os/android lang/ko-KR device/emulator',
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
        final bcode = doc['code']; // ✅ bcode 추출

        final townName = "$sido $sigungu $eupmyeondong".trim();

        print('🧭 카카오 주소: $townName');
        print('🏷️ 법정동 코드(bcode): $bcode');

        return {
          'townName': townName,
          'bcode': bcode,
        }; // ✅ Map 리턴
      }
    } else {
      print('❌ 주소 조회 실패: ${response.body}');
    }
    return null;
  }

  Future<void> _saveTownAndBcode(String townName, String bcode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTown', townName);
    await prefs.setString('selectedBcode', bcode);
    selectedTown.value = townName;
    final feedController = Get.find<FeedController>();
    await feedController.reload();
  }
}
