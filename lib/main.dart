import 'package:cocafe/controllers/authcontroller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/feedcontroller.dart';
import 'controllers/towncontroller.dart';
import 'src/app.dart';
// 앱의 시작점 , root를 설정

void main() async {
  await dotenv.load(fileName: '.env'); // 보안 키 env 읽어오기
  await GetStorage.init();  // ← 반드시 앱 시작 시 초기화
  WidgetsFlutterBinding.ensureInitialized();
  AuthRepository.initialize(appKey: dotenv.get('appKey'));
  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: dotenv.get('nativeAppKey'),
    javaScriptAppKey: dotenv.get('appKey'),
  );
  await Firebase.initializeApp();
  Get.put(AuthController());
  Get.put(FeedController());
  final townController = Get.put(TownController());
  await townController.loadSelectedTown();
  runApp(const MyApp());
}

