import 'package:flutter/material.dart';
import 'package:cs_task_managment/core/services/dialog_service.dart';
import 'package:provider/provider.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;

  const CustomDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Stack(
          children: [
            child,
            _getDialog(context),
          ],
        );
      },
    );
  }

  Widget _getDialog(BuildContext context) {
    final dialogService = Provider.of<DialogService>(context);
    return StreamBuilder<DialogRequest>(
      stream: dialogService.dialogStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final dialogRequest = snapshot.data!;

        return AlertDialog(
          title: Text(dialogRequest.title),
          content: Text(dialogRequest.description),
          actions: [
            if (dialogRequest.buttonTitle != null)
              TextButton(
                onPressed: () {
                  dialogService.dismissDialog();
                  // Handle positive action
                },
                child: Text(dialogRequest.buttonTitle!),
              ),
            if (dialogRequest.cancelTitle != null)
              TextButton(
                onPressed: () {
                  dialogService.dismissDialog();
                  // Handle negative action
                },
                child: Text(dialogRequest.cancelTitle!),
              ),
          ],
        );
      },
    );
  }
}
