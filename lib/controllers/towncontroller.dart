import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  var isAutoSetupComplete = false.obs; // 자동 설정 완료 상태 추적

  @override
  void onInit() {
    super.onInit();
    _initializeLocation(); // 컨트롤러 초기화 시 자동 위치 설정
  }

  // 앱 초기 진입 시 자동 위치 설정
  Future<void> _initializeLocation() async {
    try {
      // JSON 로드와 위치 설정을 병렬로 처리
      if (kDebugMode) {
        print('📍 앱 시작 → 현재 위치로 자동 설정 시작');
      }
      await Future.wait([
        loadLocations(), // JSON 파일 로드
        _autoSetupCurrentLocation(), // 위치 설정
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 초기 위치 설정 실패: $e');
      }
      isAutoSetupComplete.value = true; // 실패해도 완료로 처리
    }
  }

  // 자동 현재 위치 설정 (사용자 액션 없이)
  Future<void> _autoSetupCurrentLocation() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 권한이 거부되면 스킵
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('📍 위치 권한 거부됨 → 자동 설정 스킵');
        }
        isAutoSetupComplete.value = true;
        return;
      }

      // 먼저 빠른 캐시된 위치 시도, 실패하면 새 위치 가져오기
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position == null) {
          throw Exception('캐시된 위치 없음');
        }
        if (kDebugMode) {
          print('📍 캐시된 위치 사용 완료');
        }
      } catch (e) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        );
        if (kDebugMode) {
          print('📍 새 위치 획득 완료');
        }
      }
      print('📍 현재 위치: ${position.latitude}, ${position.longitude}');

      final locationData =
      await fetchAddressFromLatLng(position.latitude, position.longitude);

      if (locationData != null) {
        final townName = locationData['townName']!;
        final bcode = locationData['bcode']!;
        await _saveTownAndBcode(townName, bcode);
        if (kDebugMode) {
          print('✅ 자동 위치 설정 완료: $townName');
        }
      } else {
        print('❌ 현재 위치의 동네를 찾을 수 없음');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 자동 위치 설정 실패: $e');
      }
    } finally {
      isAutoSetupComplete.value = true; // 성공/실패 관계없이 완료로 처리
    }
  }

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

    if (kDebugMode) {
      print('✅ 동네 저장 완료: $townName');
    }

    final feedController = Get.find<FeedController>();
    await feedController.reload();
  }

  Future<void> loadSelectedTown() async {
    final prefs = await SharedPreferences.getInstance();
    selectedTown.value = prefs.getString('selectedTown') ?? '';
  }

  // 수동 현재 위치 설정 (사용자가 메뉴에서 선택)
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
        await _saveTownAndBcode(townName, bcode);
        Get.back();
        if (kDebugMode) {
          print('📍 수동 현재 위치 설정 완료: $townName');
        }
        Get.snackbar('알림', '현재 위치로 동네가 설정되었습니다: $townName');
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

        if (kDebugMode) {
          print('🧭 카카오 주소: $townName');
          print('🏷️ 법정동 코드 확인 완룼');
        }

        return {
          'townName': townName,
          'bcode': bcode,
        }; // ✅ Map 리턴
      }
    } else {
      if (kDebugMode) {
        print('❌ 주소 조회 실패');
      }
    }
    return null;
  }

  Future<void> _saveTownAndBcode(String townName, String bcode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTown', townName);
    await prefs.setString('selectedBcode', bcode);
    selectedTown.value = townName;

    // FeedController가 존재할 때만 reload
    try {
      final feedController = Get.find<FeedController>();
      await feedController.reload();
    } catch (e) {
      print('FeedController를 찾을 수 없음 (정상적인 초기화 과정)');
    }
  }

  // 자동 설정이 완료될 때까지 기다리는 메서드
  Future<void> waitForAutoSetup() async {
    while (!isAutoSetupComplete.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> reinitialize() async {
    isAutoSetupComplete.value = false; // 다시 초기화 상태로
    await _initializeLocation(); // 기존 로직 그대로 실행
  }
}