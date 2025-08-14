import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLinkController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> openNaverMapSearch(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      final data = doc.data();
      if (data == null) return;

      final query = data['shop_name'] ?? data['address'];
      if (query == null) return;

      final encoded = Uri.encodeComponent(query);
      final url = Uri.parse('https://map.naver.com/v5/search/$encoded');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (kDebugMode) {
          print("❗URL 실행 불가");
        }
      }
    } catch (e) {
      print('🔥 네이버 지도 검색 실패: $e');
    }
  }
}
