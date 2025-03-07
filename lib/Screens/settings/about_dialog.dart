import 'package:flutter/material.dart';
import 'package:t_h_m/generated/l10n.dart';

void showCustomAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(S.of(context).about_app),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).app_title),
            SizedBox(height: 8),
            Text("${S.of(context).version}: 1.0.0"),
            SizedBox(height: 8),
            Text("${S.of(context).developedBy}: THM team"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).close),
          ),
        ],
      );
    },
  );
}
