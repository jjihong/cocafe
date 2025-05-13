import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../providers/postprovider.dart';
import '../screens/feed/index.dart';
import '../screens/home.dart';

class PostController extends GetxController {
  // 입력
  final titleController = TextEditingController();
  final shopNameController = TextEditingController();
  final addressController = TextEditingController();
  final contentController = TextEditingController();
  final menuController = TextEditingController();

  final region1 = ''.obs;
  final region2 = ''.obs;
  final region3 = ''.obs;
  final bcode = ''.obs;

  final PostProvider postProvider = PostProvider();
  final storage = FirebaseStorage.instance;
  final isUploading = false.obs; // 업로드 상태 관리용

  // 내가 올릴 이미지, 태그
  var images = <XFile>[].obs;
  final RxList<String> selectedTags = <String>[].obs;
  final List<Map<String, dynamic>> tagOptions = [
    {'label': '코드 많은', 'icon': Icons.electric_bolt},
    {'label': '2층 이상', 'icon': Icons.looks_two_rounded},
    {'label': '조용한', 'icon': Icons.volume_mute},
    {'label': '스터디룸', 'icon': Icons.book},
  ];

  // 임시저장

  // 이미지 선택
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      images.addAll(pickedFiles.take(10 - images.length));
    }
  }

  // 이미지 삭제
  void removeImage(int index) {
    images.removeAt(index);
  }

  Future<void> submitPost() async {
    if (isUploading.value) return; // 중복 업로드 방지

    final title = titleController.text.trim();
    final shopName = shopNameController.text.trim();
    final address = addressController.text.trim();
    final content = contentController.text.trim();
    final menu = menuController.text.trim();
    final tagList = selectedTags.toList();

    // 1) 최소 유효성 검사
    if (title.isEmpty || shopName.isEmpty) {
      Get.snackbar('오류', '제목과 가게 이름은 필수입니다.');
      return;
    }
    isUploading.value = true; // ✨ 업로드 시작 표시
    List<String> imageUrls = [];
    try {
      const int concurrency = 3;
      for (int i = 0; i < images.length; i += concurrency) {
        final batch = images.skip(i).take(concurrency).map((xfile) async {
          final bytes = await File(xfile.path).readAsBytes();
          final name = '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
          final snap = await storage.ref('posts/$name').putData(bytes);
          return snap.ref.getDownloadURL();
        }).toList();

        final results = await Future.wait(batch);
        imageUrls.addAll(results);
      }

      await postProvider.uploadPost(
        title: title,
        shopName: shopName,
        address: address,
        content: content,
        recommendMenu: menu.isEmpty ? null : menu,
        tags: tagList,
        imageUrls: imageUrls,
        region1: region1.value,
        region2: region2.value,
        region3: region3.value,
        bcode: bcode.value,
      );

      clearAll();
      isUploading.value = false; // ✨ 항상 false로 복귀
      Get.snackbar('완료', '게시글이 성공적으로 업로드되었습니다.');
      Get.offAll(() => const Home());
    } catch (e) {
      Get.snackbar('업로드 실패', e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  void clearAll() {
    titleController.clear();
    shopNameController.clear();
    addressController.clear();
    contentController.clear();
    menuController.clear();
    images.clear();
  }

  @override
  void onClose() {
    // 메모리 누수 방지: 컨트롤러 해제
    titleController.dispose();
    shopNameController.dispose();
    addressController.dispose();
    contentController.dispose();
    menuController.dispose();
    super.onClose();
  }

  Future<Map<String, dynamic>?> fetchRegionInfo(String address) async {
    if (address.trim().isEmpty) return null;

    final uri = Uri.https(
      'dapi.kakao.com',
      '/v2/local/search/address.json',
      {
        'query': address,
        'analyze_type': 'similar', // 유사 주소 허용 (선택)
      },
    );

    final resp = await http.get(uri, headers: {
      'Authorization': '${dotenv.get('KAKAO_REST_API_KEY')}',
    });

    print('DEBUG: status=${resp.statusCode}, body=${resp.body}'); // ⬅️ 꼭 확인

    if (resp.statusCode == 200) {
      final jsonBody = jsonDecode(resp.body);
      final docs = (jsonBody['documents'] as List).cast<Map<String, dynamic>>();
      return docs.isNotEmpty ? docs.first['address'] : null;
    }

    return null;
  }
}
