import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/profilecontroller.dart';

class ProfileEditScreen extends StatefulWidget {
  final String? currentName;
  final String? currentImageUrl;

  const ProfileEditScreen({
    super.key,
    this.currentName,
    this.currentImageUrl,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController nameTextController;
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController());

    if (controller.name.value.isEmpty && widget.currentName != null) {
      controller.setName(widget.currentName!);
    }
    if (controller.imageUrl.value.isEmpty && widget.currentImageUrl != null) {
      controller.setImageUrl(widget.currentImageUrl!);
    }

    nameTextController = TextEditingController(text: controller.name.value);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      controller.setImage(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: pickImage,
              child: Center(
                child: Obx(() {
                  final file = controller.imageFile.value;

                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: file != null
                            ? FileImage(file)
                            : (controller.imageUrl.value.isNotEmpty
                                    ? NetworkImage(controller.imageUrl.value)
                                    : const AssetImage('asset/copeng.png'))
                                as ImageProvider,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameTextController,
              onChanged: controller.setName,
              decoration: const InputDecoration(
                hintText: '이름을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await controller.saveProfile();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('수정하기'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameTextController.dispose();
    super.dispose();
  }
}
