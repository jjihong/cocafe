import 'package:cocafe/widgets/custom_save_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        onSave: () => widget.onSave?.call(),
        onDiscard: () => widget.onDiscard?.call(),
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
