import 'package:flutter/material.dart';
import 'package:t_h_m/Screens/Patient_info/patient_info_screen.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'vital_signs_card.dart';
import 'package:t_h_m/Screens/Patient_info/patient_info_firebase.dart';

class VitalSignsScreen extends StatelessWidget {
  final String bedNumber;
  final String docId;
  final String bedName;
  final int age;
  final String gender;
  final String phoneNumber;
  final String doctorName;
  final String userRole;

  const VitalSignsScreen({
    Key? key,
    required this.docId,
    required this.bedNumber,
    required this.bedName,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.doctorName,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).vital_signs,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () async {
              String userRole = await getUserRole();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientInfoScreen(
                    docId: docId,
                    bedNumber: bedNumber,
                    bedName: bedName,
                    age: age,
                    gender: gender,
                    phoneNumber: phoneNumber,
                    doctorName: doctorName,
                    userRole: userRole,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VitalSignCard(
                icon: Icons.favorite, label: 'Heart Rate', value: '75 BPM'),
            VitalSignCard(
                icon: Icons.thermostat, label: 'Temperature', value: '36.5°C'),
            VitalSignCard(
                icon: Icons.bubble_chart, label: 'Oxygen Level', value: '98%'),
          ],
        ),
      ),
    );
  }
}
