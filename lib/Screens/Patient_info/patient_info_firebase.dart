import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_info_screen.dart';
import 'patient_info_dialogs.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';

extension PatientFirestoreMethods on PatientInfoScreenState {
  Future<int> loadPatientId() async {
    try {
      final counterDoc = await FirebaseFirestore.instance
          .collection('beds')
          .doc(widget.docId)
          .get();

      if (counterDoc.exists && counterDoc['patientId'] != null) {
        return counterDoc['patientId'];
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('Error loading patientId: $e');
      return 0;
    }
  }

  Future<void> deletePatient(String docId) async {
    try {
      final patientDoc =
          await FirebaseFirestore.instance.collection('beds').doc(docId).get();

      if (patientDoc.exists) {
        final patientData = patientDoc.data() as Map<String, dynamic>;
        patientData['deletedAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('previous patients')
            .doc(docId)
            .set(patientData);

        await FirebaseFirestore.instance.collection('beds').doc(docId).delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Patient moved to archive!")),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => AddBedsScreen()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Patient not found!")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to move patient to archive!")),
      );
    }
  }
}
