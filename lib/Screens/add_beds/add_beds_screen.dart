import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:t_h_m/Screens/add_beds/add_bed_dialog.dart';
import 'package:t_h_m/Screens/add_beds/bed_item.dart';
import 'package:t_h_m/Screens/settings/settings_screen.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'dialogs.dart';
import 'add_beds_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddBedsScreen extends StatefulWidget {
  @override
  _AddBedsScreenState createState() => _AddBedsScreenState();
}

class _AddBedsScreenState extends State<AddBedsScreen> {
  String? userRole;
  bool isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<String> doctorNames = []; // قائمة الأطباء
  String? selectedDoctor; // الطبيب المختار

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    String? role = await _firebaseService.getUserRole();
    setState(() {
      userRole = role;
      isLoading = false;
    });
  }

  Future<String> getUserRole() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (currentUserId.isEmpty) return "Unknown";

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return (userDoc.data() as Map<String, dynamic>)['Role'] ?? "Unknown";
      } else {
        return "Unknown"; // إذا لم يكن لديه دور
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return "Unknown";
    }
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await Dialogs.showExitDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: S.of(context).search,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                )
              : Text(
                  S.of(context).app_title,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            // زر البحث
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchController.clear();
                    searchQuery = '';
                  }
                  _isSearching = !_isSearching;
                });
              },
            ),
            // زر الإعدادات
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
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
            var beds = snapshot.data!.docs.where((bed) {
              var bedData = bed.data() as Map<String, dynamic>;
              var patientName =
                  bedData['bedName']?.toString().toLowerCase() ?? "";
              return searchQuery.isEmpty || patientName.contains(searchQuery);
            }).toList();

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
                  userRole: userRole ?? "Unknown", // ✅ تمرير الدور بعد تحميله
                );
              },
            );
          },
        ),
        floatingActionButton: (userRole == "Admin") // ✅ زر يظهر فقط للإدمن
            ? FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AddBedDialog(),
                  );
                },
                backgroundColor: AppColors.primaryColor,
                child:
                    Icon(Icons.add, color: Theme.of(context).iconTheme.color),
              )
            : null, // إذا لم يكن المستخدم Admin، لن يظهر الزر
      ),
    );
  }
}
