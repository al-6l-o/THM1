import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  // دالة لحفظ بيانات السرير في Firebase
  static Future< // دالة لحفظ البيانات في Firebase
      void> saveBedData(
    String bedNumber,
    String bedName,
    int age,
    String gender,
    String phoneNumber,
    String doctorName,
    BuildContext context,
  ) async {
// الحصول على العداد الحالي من Firebase
    DocumentSnapshot counterSnapshot = await FirebaseFirestore.instance
        .collection('settings')
        .doc('counter')
        .get();
    int currentCounter =
        counterSnapshot.exists ? counterSnapshot['patientId'] : 0;

    // زيادة العداد للحصول على id تصاعدي جديد
    int newPatientId = currentCounter + 1;

    // تحديث العداد في Firebase ليكون الرقم التالي
    await FirebaseFirestore.instance
        .collection('settings')
        .doc('counter')
        .update({
      'patientId': newPatientId,
    });

    FirebaseFirestore.instance.collection('beds').add({
      'patientId': newPatientId,
      'bedNumber': bedNumber,
      'bedName': bedName,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'doctorName': doctorName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
