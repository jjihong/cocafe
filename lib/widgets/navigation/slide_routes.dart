// widgets/navigation/slide_routes.dart

import 'package:flutter/material.dart';

// 뒤로가기용 슬라이드 애니메이션 PageRoute
class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;
  
  SlideLeftRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); // 왼쪽에서 시작
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// 앞으로가기용 슬라이드 애니메이션 PageRoute  
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  
  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // 오른쪽에서 시작
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// 히스토리 아이템 클래스
class HistoryItem {
  final String postId;
  final double scrollOffset;
  
  HistoryItem({required this.postId, required this.scrollOffset});
}