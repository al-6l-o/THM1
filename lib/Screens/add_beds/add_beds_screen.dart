import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:t_h_m/Screens/add_beds/add_bed_dialog.dart';
import 'package:t_h_m/Screens/add_beds/bed_item.dart';
import 'package:t_h_m/Screens/settings/settings_screen.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'dialogs.dart';

class AddBedsScreen extends StatefulWidget {
  @override
  _AddBedsScreenState createState() => _AddBedsScreenState();
}

class _AddBedsScreenState extends State<AddBedsScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await Dialogs.showExitDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).app_title,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              icon: Icon(Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('beds')
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  S.of(context).no_beds_yet,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              );
            }
            var beds = snapshot.data!.docs;

            return ListView.builder(
              itemCount: beds.length,
              itemBuilder: (context, index) {
                var bed = beds[index];
                var bedData = bed.data() as Map<String, dynamic>?;

                return BedItem(
                  docId: bed.id,
                  bedNumber: bedData?['bedNumber'] ?? 'Unknown',
                  bedName: bedData?['bedName'] ?? 'Unknown',
                  age: bedData?['age'] ?? 0,
                  gender: bedData?['gender'] ?? 'Unknown',
                  phoneNumber: bedData?['phoneNumber'] ?? 'Unknown',
                  doctorName: bedData?['doctorName'] ?? 'Unknown',
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AddBedDialog(),
            );
          },
          backgroundColor: AppColors.primaryColor,
          child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }
}
