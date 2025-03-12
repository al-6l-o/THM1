import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';

extension PatientInfoDialogs on State {
  // دالة لعرض التنبيه إذا كان رقم السرير مكررًا///////////////////////////////
  void showDuplicateBedNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text(
          S.of(context).bed_exists,
          style: TextStyle(
              color: Theme.of(context).colorScheme.error, fontSize: 18),
        ),
        content: Text(
          S.of(context).enter_another_number,
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).ok,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

///////////////////////////////////////////////////////////////////////////////////
  void showEditConfirmationDialog(VoidCallback onVerified) {
    bool isError = false;
    String errorMessage = "";
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            S.of(context).confirm_modification_title,
            style:
                TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: S.of(context).confirm_modification_content,
                  labelStyle: const TextStyle(fontSize: 14),
                  errorText: isError ? errorMessage : null,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (codeController.text == "1234") {
                  Navigator.of(context).pop();
                  onVerified();
                } else {
                  setState(() {
                    isError = true;
                    errorMessage = S.of(context).message_incorrect_number;
                  });
                }
              },
              child: Text(S.of(context).Confirm),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

/////////////////////////////////////////////////////////////////////////////
  void showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animations/warning.json',
                width: 75, height: 75, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(S.of(context).confirm_deleted_bed,
                style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('beds')
                  .doc(docId)
                  .delete();
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => AddBedsScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(S.of(context).delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
