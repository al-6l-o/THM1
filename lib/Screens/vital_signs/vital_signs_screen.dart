import 'package:flutter/material.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:t_h_m/Screens/Patient_info/patient_info.dart';
import 'package:t_h_m/generated/l10n.dart';

class VitalSignsScreen extends StatelessWidget {
  final String bedNumber;
  final String docId;
  final String bedName;
  final int age;
  final String gender;
  final String phoneNumber;
  final String doctorName;

  const VitalSignsScreen({
    Key? key,
    required this.docId,
    required this.bedNumber,
    required this.bedName,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.doctorName,
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
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu,
                  color: Theme.of(context).colorScheme.onPrimary),
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // فتح القائمة الجانبية
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90, // تقليل الارتفاع لجعل "Settings" أصغر
              color: Theme.of(context).colorScheme.primary,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                S.of(context).patient_settings,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 22, // تصغير حجم النص قليلاً
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    S.of(context).patient_informations,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 18),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // إغلاق القائمة الجانبية
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
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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

class VitalSignCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const VitalSignCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).colorScheme.background,
      child: ListTile(
        leading: Icon(icon,
            color: Theme.of(context).colorScheme.onBackground, size: 30),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground)),
        subtitle: Text(value,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground)),
      ),
    );
  }
}
