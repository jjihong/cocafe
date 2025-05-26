import 'package:flutter/material.dart';

import '../custom_save_dialog.dart';

class ExitConfirmWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onDiscard;
  final bool Function()? isModified;

  const ExitConfirmWrapper({
    super.key,
    required this.child,
    this.onSave,
    this.onDiscard,
    this.isModified,
  });

  @override
  State<ExitConfirmWrapper> createState() => _ExitConfirmWrapperState();
}

class _ExitConfirmWrapperState extends State<ExitConfirmWrapper> {
  Future<void> _handleExitAndPop(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomSaveDialog(
        title: '작성 중인 글을 저장할까요?',
        description: '지금 나가면 작성한 내용이 사라져요.',
        saveButtonText: '저장하기',
        discardButtonText: '저장 안 함',
        onSave: () {
          widget.onSave?.call();
          Navigator.of(context).pop(true);
        },
        onDiscard: () {
          widget.onDiscard?.call();
          Navigator.of(context).pop(false);
        },
      ),
    );

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
