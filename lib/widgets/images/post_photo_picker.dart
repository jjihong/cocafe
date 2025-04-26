import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class PostPhotoPicker extends StatelessWidget {
  final List<XFile> images;
  final void Function(List<XFile>) onImagesChanged;

  const PostPhotoPicker({
    super.key,
    required this.images,
    required this.onImagesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableBuilder<XFile>(
      onReorder: (reorderFunc) {
        final updated = reorderFunc([...images]);
        onImagesChanged(updated);
      },
      builder: (children) {
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            ...children,
            if (images.length < 5)
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFiles = await picker.pickMultiImage();
                  if (pickedFiles.isNotEmpty) {
                    final newImages = [...images, ...pickedFiles].take(5).toList();
                    onImagesChanged(newImages);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 30),
                ),
              ),
          ],
        );
      },
      children: List.generate(images.length, (i) {
        return CustomDraggable(
          key: ValueKey(images[i].path),
          data: images[i],
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(images[i].path)),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: IconButton(
                  icon: const Icon(Icons.cancel, size: 20),
                  onPressed: () {
                    final updated = [...images];
                    updated.removeAt(i);
                    onImagesChanged(updated);
                  },
                ),
              ),
              if (i == 0)
                const Positioned(
                  bottom: 4,
                  left: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        '대표사진',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
