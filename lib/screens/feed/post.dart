import 'package:cocafe/widgets/buttons/categorybutton.dart';
import 'package:cocafe/widgets/popupmenus/exit_confirm_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/postcontroller.dart';
import '../../widgets/buttons/submit_button.dart';
import '../../widgets/images/post_photo_picker.dart';
import '../../widgets/textfields/custom_text_field.dart';

class Post extends StatelessWidget {
  Post({super.key});

  final controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return ExitConfirmWrapper(
      child: Obx(
        () => Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text('글 작성하기'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: () {
                        debugPrint('📦 수동으로 임시저장');
                      },
                      child: const Text(
                        '임시저장',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: controller.titleController,
                      label: '제목',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.shopNameController,
                      label: '가게 이름',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.addressController,
                      label: '주소',
                    ),
                    const SizedBox(height: 16),
                    const Text(" 사진 (5장까지)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Obx(() => PostPhotoPicker(
                          images: controller.images.toList(),
                          onImagesChanged: (imgs) =>
                              controller.images.assignAll(imgs), // ✅ 핵심!
                        )),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.contentController,
                      label: '내용',
                      maxLines: 8,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.menuController,
                      label: '추천 메뉴',
                    ),
                    const SizedBox(height: 16),
                    const Text(" 태그 선택",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Obx(() => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: controller.tagOptions.map((tag) {
                              final isSelected = controller.selectedTags
                                  .contains(tag['label']);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CategoryButton(
                                  icon: tag['icon'],
                                  title: tag['label'],
                                  selected: isSelected,
                                  onTap: () {
                                    if (isSelected) {
                                      controller.selectedTags
                                          .remove(tag['label']);
                                    } else {
                                      controller.selectedTags.add(tag['label']);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        )),
                  ],
                ),
              ),
              bottomNavigationBar: const SubmitButton(),
            ),
            if (controller.isUploading.value)
              Container(
                color: Colors.black.withOpacity(0.3), // 🔹 반투명 배경
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '게시글 업로드 중...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
