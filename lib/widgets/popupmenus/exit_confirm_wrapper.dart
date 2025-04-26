import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExitConfirmWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSave;
  final bool Function()? isModified;

  const ExitConfirmWrapper({
    super.key,
    required this.child,
    this.onSave,
    this.isModified,
  });

  @override
  State<ExitConfirmWrapper> createState() => _ExitConfirmWrapperState();
}

class _ExitConfirmWrapperState extends State<ExitConfirmWrapper> {
  Future<void> _handleExitAndPop(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: const Text('임시저장할까요?'),
        content: const Text('지금 나가면 작성 중인 내용이 사라져요.\n임시저장 하시겠어요?'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('취소'),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('아니요'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      widget.onSave?.call();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('예'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // 팝 여부와 상관없이 예/아니요 누르면 pop
    if (shouldExit == true || shouldExit == false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (widget.isModified != null && widget.isModified!.call() == false) {
            Navigator.of(context).maybePop();
            return;
          }

          await _handleExitAndPop(context);
        }
      },
      child: widget.child,
    );
  }
}
