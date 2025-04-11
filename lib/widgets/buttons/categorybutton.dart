import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String? title;
  final bool selected; // ✅ 선택 여부

  const CategoryButton({
    required this.icon,
    this.onTap,
    this.title,
    this.selected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.blue.withOpacity(0.2), // 누를 때 효과
      onTap: onTap,
      child: AnimatedContainer(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(milliseconds: 200),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Icon(
                icon, size: 16,
                color: selected ? Colors.blue : Colors.grey[600], // ✅ 아이콘 색상
              ),
            ), // 아이콘 표시
            if (title != null) const SizedBox(width: 8),
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.blue : Colors.grey[600], // ✅ 글자 색상
                ),
              ),
          ],
        ),
      ),
    );
  }
}
