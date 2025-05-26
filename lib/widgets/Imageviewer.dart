// image_viewer.dart

import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  const ImageViewer({Key? key, required this.photos, required this.initialIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: initialIndex);
    final ValueNotifier<int> currentPage = ValueNotifier<int>(initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true, // ✅ 홈버튼 뒤 배경 유지
      body: Stack(
        children: [
          Positioned(
            child: PageView.builder(
              controller: controller,
              itemCount: photos.length,
              onPageChanged: (index) => currentPage.value = index,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 72,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (_, value, __) => Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${value + 1} / ${photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}