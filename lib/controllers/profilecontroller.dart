import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final name = ''.obs;
  final imageFile = Rx<File?>(null);

  final imageUrl = ''.obs;

  void setImageUrl(String url) {
    imageUrl.value = url;
  }

  void setName(String newName) {
    name.value = newName;
  }

  void setImage(File? file) {
    imageFile.value = file;
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();
    final data = doc.data();
    final currentName = data?['name'] ?? '';
    final currentImage = data?['profile_img'] ?? '';

    // 이미지 바뀐 경우에만 업로드
    String? uploadedImageUrl;
    if (imageFile.value != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');
      await ref.putFile(imageFile.value!);
      uploadedImageUrl = await ref.getDownloadURL();
    }

    final newName = name.value.trim();
    final newImage = uploadedImageUrl ?? imageUrl.value;

    final nameChanged = newName != currentName;
    final imageChanged =
        uploadedImageUrl != null && uploadedImageUrl != currentImage;

    if (!nameChanged && !imageChanged) {
      Get.back();
      return;
    }

    await userRef.update({
      'name': newName,
      if (imageChanged) 'profile_img': newImage,
    });

    Get.back(result: true);
  }
}
