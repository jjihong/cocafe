import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'controllers/towncontroller.dart';
import 'src/app.dart';
// 앱의 시작점 , root를 설정

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AuthRepository.initialize(appKey: 'ec73444016c089b9135bece06ea0166a');
  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '7f91f980c97d305201065841b4be0025',
  );
  final townController = Get.put(TownController());
  await townController.loadSelectedTown();
  runApp(const MyApp());
}

