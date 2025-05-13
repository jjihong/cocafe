import 'package:cocafe/widgets/buttons/categorybutton.dart';
import 'package:cocafe/widgets/popupmenus/exit_confirm_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/postcontroller.dart';
import '../../models/place.dart';
import '../../widgets/buttons/submit_button.dart';
import '../../widgets/images/post_photo_picker.dart';
import '../../widgets/textfields/custom_text_field.dart';
import 'address.dart';

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
                      readOnly: true, // 직접 타이핑 못하게 막아
                      onTap: () async {
                        final Place? result = await Get.to(() => const AddressSearchScreen());
                        if (result != null) {
                          controller.shopNameController.text = result.name;
                          controller.addressController.text = result.roadAddress ?? result.address;

                          controller.shopNameController.text = result.name;
                          controller.addressController.text = result.roadAddress ?? result.address;

                          // 📌 address API 호출해서 b_code 얻기
                          final region = await controller.fetchRegionInfo(result.address);
                          if (region != null) {
                            controller.region1.value = region['region_1depth_name'] ?? '';
                            controller.region2.value = region['region_2depth_name'] ?? '';
                            controller.region3.value = region['region_3depth_name'] ?? '';
                            controller.bcode.value = region['b_code'] ?? '';
                          }
                        }
                      },
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
