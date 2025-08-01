import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../controllers/feedcontroller.dart';
import '../providers/postprovider.dart';
import '../screens/home.dart';

class PostController extends GetxController {
  // ✏️ 수정 모드 플래그
  final isEditMode = false.obs;
  String? editingPostId;

  // 입력 컨트롤러 및 state
  final titleController = TextEditingController();
  final shopNameController = TextEditingController();
  final addressController = TextEditingController();
  final contentController = TextEditingController();
  final menuController = TextEditingController();

  final region1 = ''.obs;
  final region2 = ''.obs;
  final region3 = ''.obs;
  final bcode = ''.obs;
  final lat = ''.obs;
  final lng = ''.obs;

  final PostProvider postProvider = PostProvider();
  final storage = FirebaseStorage.instance;
  final isUploading = false.obs; // 업로드 상태 관리용

  var images = <XFile>[].obs;
  // 태그 옵션 목록
  final List<Map<String, dynamic>> tagOptions = [
    {'label': '코드 많은', 'icon': Icons.electric_bolt},
    {'label': '2층 이상', 'icon': Icons.looks_two_rounded},
    {'label': '조용한', 'icon': Icons.volume_mute},
    {'label': '스터디룸', 'icon': Icons.book},
  ];
  final RxList<String> selectedTags = <String>[].obs;

  /// 모든 입력 필드 초기화
  void clearAll() {
    titleController.clear();
    shopNameController.clear();
    addressController.clear();
    contentController.clear();
    menuController.clear();
    images.clear();
    selectedTags.clear();
    region1.value = '';
    region2.value = '';
    region3.value = '';
    bcode.value = '';
    lat.value = '';
    lng.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    clearAll();
    loadDraftIfExists(); // ✏️ 임시저장 로드
  }

  /// ✏️ 수정 모드 진입 시, 기존 데이터 로드
  Future<void> loadForEdit(String postId) async {
    final post = await postProvider.getPostById(postId);
    if (post == null) {
      Get.snackbar('오류', '게시글을 불러올 수 없습니다.');
      return;
    }
    titleController.text = post.title;
    shopNameController.text = post.shopName;
    addressController.text = post.address;
    contentController.text = post.content;
    menuController.text = post.recommendMenu;
    selectedTags.assignAll(post.tags);
    images.assignAll(post.photos.map((url) => XFile(url)).toList());
    region1.value = post.region1;
    region2.value = post.region2;
    region3.value = post.region3;
    bcode.value = post.bcode;
    lat.value = post.lat;
    lng.value = post.lng;

    isEditMode.value = true;
    editingPostId = postId;
  }

  /// ✏️ 신규 작성
  Future<void> createPost() => _submitPost(isUpdate: false);

  /// ✏️ 수정 제출
  Future<void> updatePost() => _submitPost(isUpdate: true);

  /// 공통: 등록/수정
  Future<void> _submitPost({ required bool isUpdate }) async {
    if (isUploading.value) return;
    final title = titleController.text.trim();
    final shopName = shopNameController.text.trim();
    if (title.isEmpty || shopName.isEmpty) {
      Get.snackbar('오류', '제목과 가게 이름은 필수입니다.');
      return;
    }
    isUploading.value = true;
    List<String> imageUrls = [];

    try {
      // 이미지 업로드 로직 (기존 submitPost 내용 복사)

      if (images.isNotEmpty) {
        for (final xfile in images) {
          if (xfile.path.startsWith('http')) {
            // 이미 업로드된 URL인 경우 → 재사용만 하고 업로드는 건너뛰기
            imageUrls.add(xfile.path);
          } else {
            // 새로 선택한 로컬 파일만 Firebase Storage에 업로드
            final bytes = await File(xfile.path).readAsBytes();
            final name = '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
            final snap = await storage.ref('posts/$name').putData(bytes);
            imageUrls.add(await snap.ref.getDownloadURL());
          }
        }
      } else {
        final randomAsset = ['asset/codog.png','asset/copeng.png','asset/cocat.png'][Random().nextInt(3)];
        final data = await rootBundle.load(randomAsset);
        final bytes = data.buffer.asUint8List();
        final fileName = 'default_${DateTime.now().millisecondsSinceEpoch}_${randomAsset.split('/').last}';
        final snap = await storage.ref('posts/$fileName').putData(bytes);
        imageUrls.add(await snap.ref.getDownloadURL());
      }

      if (isUpdate) {
        final data = {
          'title': title,
          'shop_name': shopName,
          'address': addressController.text.trim(),
          'content': contentController.text.trim(),
          'recommend_menu': menuController.text.trim(),
          'tags': selectedTags.toList(),
          'photos': imageUrls,
          'region1': region1.value,
          'region2': region2.value,
          'region3': region3.value,
          'bcode': bcode.value,
          'lat': lat.value,
          'lng': lng.value,
        };
        await postProvider.updatePost(postId: editingPostId!, data: data);
        Get.snackbar('완료', '게시글이 수정되었습니다.');
      } else {
        await postProvider.uploadPost(
          title: title,
          shopName: shopName,
          address: addressController.text.trim(),
          content: contentController.text.trim(),
          recommendMenu: menuController.text.trim().isEmpty ? null : menuController.text.trim(),
          tags: selectedTags.toList(),
          imageUrls: imageUrls,
          region1: region1.value,
          region2: region2.value,
          region3: region3.value,
          bcode: bcode.value,
          lat: lat.value,
          lng: lng.value,
        );
        Get.snackbar('완료', '게시글이 성공적으로 업로드되었습니다.');
      }

      await postProvider.deleteDraft();
      
      // 수정 모드인 경우 FeedController 리로드하고 FeedIndex로 돌아가기
      if (isUpdate) {
        // FeedController가 등록되어 있다면 리로드
        if (Get.isRegistered<FeedController>()) {
          Get.find<FeedController>().reload();
        }
        clearAll();
        Get.offAll(() => const Home()); // FeedIndex로 바로 돌아가기
      } else {
        clearAll();
        Get.offAll(() => const Home());
      }
    } catch (e) {
      Get.snackbar(isUpdate ? '수정 실패' : '업로드 실패', e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  /// 임시저장
  Future<void> saveAsDraft() async {
    final title = titleController.text.trim();
    final shop = shopNameController.text.trim();
    final addr = addressController.text.trim();
    final cont = contentController.text.trim();
    final menu = menuController.text.trim();
    final tags = selectedTags.toList();
    final paths = images.map((x) => x.path).toList();
    final empty = [title,shop,addr,cont,menu].every((s) => s.isEmpty) && tags.isEmpty && paths.isEmpty;
    if (empty) {
      Get.snackbar('임시저장 불가', '내용이 없습니다.');
      return;
    }
    await postProvider.saveDraft(
      title: title,
      shopName: shop,
      address: addr,
      content: cont,
      recommendMenu: menu,
      tags: tags,
      imagePaths: paths,
      region1: region1.value,
      region2: region2.value,
      region3: region3.value,
      bcode: bcode.value,
      lat: lat.value,
      lng: lng.value,
    );
    Get.snackbar('임시저장 완료', '작성 중인 글이 저장되었습니다.');
  }

  /// 임시저장 로드
  Future<void> loadDraftIfExists() async {
    final data = await postProvider.loadDraft();
    if (data == null) return;
    titleController.text = data['title'] ?? '';
    shopNameController.text = data['shop_name'] ?? '';
    addressController.text = data['address'] ?? '';
    contentController.text = data['content'] ?? '';
    menuController.text = data['recommend_menu'] ?? '';
    selectedTags.assignAll(List<String>.from(data['tags'] ?? []));
    region1.value = data['region1'] ?? '';
    region2.value = data['region2'] ?? '';
    region3.value = data['region3'] ?? '';
    bcode.value = data['bcode'] ?? '';
    lat.value = data['lat'] ?? '';
    lng.value = data['lng'] ?? '';
    final paths = List<String>.from(data['image_paths'] ?? []);
    images.assignAll(paths.map((p) => XFile(p)).toList());
  }

  /// 이미지 선택
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) images.addAll(picked.take(10 - images.length));
  }

  /// 이미지 삭제
  void removeImage(int idx) => images.removeAt(idx);

  /// 주소 정보로 지역 코드 및 위경도 조회
  Future<Map<String, dynamic>?> fetchRegionInfo(String address) async {
    if (address.trim().isEmpty) return null;
    final uri = Uri.https(
      'dapi.kakao.com',
      '/v2/local/search/address.json',
      {'query': address, 'analyze_type': 'similar'},
    );
    final resp = await http.get(uri, headers: {
      'Authorization': dotenv.get('KAKAO_REST_API_KEY'),
    });
    if (resp.statusCode == 200) {
      final jsonBody = jsonDecode(resp.body);
      final docs = (jsonBody['documents'] as List).cast<Map<String, dynamic>>();
      return docs.isNotEmpty ? docs.first['address'] : null;
    }
    return null;
  }

  @override
  void onClose() {
    titleController.dispose();
    shopNameController.dispose();
    addressController.dispose();
    contentController.dispose();
    menuController.dispose();
    super.onClose();
  }
  /// 임시저장 여부 확인
  Future<bool> hasDraft() async {
    final draft = await postProvider.loadDraft();
    return draft != null;
  }
}
