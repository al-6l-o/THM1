import 'package:flutter/material.dart';
import 'package:t_h_m/generated/l10n.dart';

void PatientChoiceScreen(BuildContext context) {
  // متغير لحفظ الخيار المحدد
  String? selectedPatientType = 'all'; // 'all' هو القيمة الافتراضية (كل المرضى)

  // دالة لفتح الـ Dialog
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(S.of(context).choice_patients),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // خيار "كل المرضى"
            RadioListTile<String>(
              title: Text(S.of(context).all_patients),
              value: 'all', // القيمة التي يتم تحديدها عند اختيار هذا الخيار
              groupValue:
                  selectedPatientType, // المتغير الذي يحتوي على القيمة المحددة
              onChanged: (value) {
                // تحديث قيمة الاختيار عند التغيير
                selectedPatientType = value;
                Navigator.pop(context); // إغلاق الـ Dialog
                // تنفيذ الكود لجلب المرضى بناءً على الخيار المحدد
                // يمكنك استدعاء دالة هنا مثل fetchPatients('all') لجلب المرضى
              },
            ),
            // خيار "مرضاي فقط"
            RadioListTile<String>(
              title: Text(S.of(context).my_patients),
              value:
                  'myPatients', // القيمة التي يتم تحديدها عند اختيار هذا الخيار
              groupValue:
                  selectedPatientType, // المتغير الذي يحتوي على القيمة المحددة
              onChanged: (value) {
                // تحديث قيمة الاختيار عند التغيير
                selectedPatientType = value;
                Navigator.pop(context); // إغلاق الـ Dialog
                // تنفيذ الكود لجلب المرضى بناءً على الخيار المحدد
                // يمكنك استدعاء دالة هنا مثل fetchPatients('myPatients') لجلب المرضى
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // إغلاق الـ Dialog
            child: Text(S.of(context).close),
          ),
        ],
      );
    },
  );
}
