import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:t_h_m/Screens/vital_signs/vital_signs_screen.dart';
import 'package:t_h_m/Screens/settings/settings_screen.dart';
import 'package:t_h_m/Providers/theme_provider.dart';
import 'package:lottie/lottie.dart';

class AddBedsScreen extends StatefulWidget {
  @override
  _AddBedsScreenState createState() => _AddBedsScreenState();
}

class _AddBedsScreenState extends State<AddBedsScreen> {
  static const int maxBeds = 10; // الحد الأقصى لعدد الأسرة

  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String bedNumber = '';
  String bedName = '';
  String age = '';
  String gender = 'Male';
  String phoneNumber = '';
  String? errorMessage; // تغيير نوع المتغير ليسمح بالقيم الفارغة

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false, // لا يمكن إغلاقه إلا بعد انتهاء الأنيميشن
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // إغلاق النافذة بعد ثانيتين
        });

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                child: Lottie.asset(
                    'assets/animations/success.json'), // تأكد من وضع الملف داخل مجلد assets
              ),
              SizedBox(height: 10),
              Text(
                'added successfully!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteBed(String bedId) {
    FirebaseFirestore.instance.collection('beds').doc(bedId).delete().then((_) {
      print('Bed deleted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bed deleted successfully!')),
      );
    }).catchError((error) {
      print('Failed to delete bed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete bed!')),
      );
    });
  }

  void _showDeleteConfirmationDialog(String bedId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete this bed?',
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق النافذة
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteBed(bedId); // استدعاء دالة الحذف
                Navigator.of(context).pop(); // إغلاق النافذة بعد الحذف
              },
              child: Text('Delete',
                  style: TextStyle(color: AppColors.warningColor)),
            ),
          ],
        );
      },
    );
  }

  // تصميم الحقول مع تأثير التركيز
  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.black),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }

  // نافذة إضافة سرير جديد
  void _showAddBedDialog() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    // التحقق من عدد الأسرة الحالية
    final bedCountSnapshot =
        await FirebaseFirestore.instance.collection('beds').get();
    int currentBedCount = bedCountSnapshot.docs.length;

    if (currentBedCount >= maxBeds) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum number of beds reached!'),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return; // الخروج من الدالة وعدم فتح نافذة الإضافة
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Bed'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: customInputDecoration('Bed Number'),
                        cursorColor: AppColors.primaryColor,
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the bed number';
                          } else if (errorMessage != null) {
                            return errorMessage;
                          }
                          return null;
                        },
                        onSaved: (value) => bedNumber = value!,
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: AppColors.warningColor),
                          ),
                        ),
                      TextFormField(
                        decoration: customInputDecoration('Name'),
                        cursorColor: AppColors.primaryColor,
                        style: TextStyle(color: Colors.black),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                        onSaved: (value) => bedName = value!,
                      ),
                      TextFormField(
                        decoration: customInputDecoration('Age'),
                        keyboardType: TextInputType.number,
                        cursorColor: AppColors.primaryColor,
                        style: TextStyle(color: Colors.black),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter age' : null,
                        onSaved: (value) => age = value!,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Gender"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: "Male",
                                      groupValue: gender,
                                      onChanged: (value) {
                                        setState(() {
                                          gender = value!;
                                        });
                                      },
                                      activeColor: AppColors.primaryColor,
                                    ),
                                    Text("Male"),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: "Female",
                                      groupValue: gender,
                                      onChanged: (value) {
                                        setState(() {
                                          gender = value!;
                                        });
                                      },
                                      activeColor: AppColors.primaryColor,
                                    ),
                                    Text("Female"),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        decoration:
                            customInputDecoration('Phone Number').copyWith(
                          prefixText: '+967 ',
                          prefixStyle: TextStyle(color: AppColors.textColor),
                        ),
                        keyboardType: TextInputType.phone,
                        cursorColor: AppColors.primaryColor,
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length != 9) {
                            return 'Phone number must be 9 digits';
                          }
                          return null;
                        },
                        onSaved: (value) => phoneNumber = value!,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final bedSnapshot = await FirebaseFirestore.instance
                      .collection('beds')
                      .where('bedNumber', isEqualTo: bedNumber)
                      .get();

                  if (bedSnapshot.docs.isNotEmpty) {
                    setState(() {
                      errorMessage = 'Bed number already exists!';
                    });
                  } else {
                    errorMessage = null;
                    // إغلاق نافذة الإدخال
                    Navigator.of(context).pop();

// حفظ بيانات السرير
                    saveBedData(bedNumber, bedName, int.tryParse(age) ?? 0,
                        gender, phoneNumber);

// عرض أنيميشن النجاح بعد إغلاق نافذة الإدخال
                    Future.delayed(Duration(milliseconds: 300), () {
                      _showSuccessAnimation();
                    });
                  }
                } else {
                  setState(() {
                    errorMessage = null;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // دالة لحفظ البيانات في Firebase
  void saveBedData(
    String bedNumber,
    String bedName,
    int age,
    String gender,
    String phoneNumber,
  ) async {
    FirebaseFirestore.instance.collection('beds').add({
      'bedNumber': bedNumber,
      'bedName': bedName,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exitApp = await _showExitDialog(context);
        return exitApp;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'THM',
            style: TextStyle(color: AppColors.backgroundColor),
          ),
          backgroundColor: AppColors.primaryColor,
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: AppColors.backgroundColor),
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
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'There are no beds added yet!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
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

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VitalSignsScreen(
                          docId: bed.id,
                          bedNumber: bedData?['bedNumber'] ?? 'Unknown',
                          bedName: bedData?['bedName'] ?? 'Unknown',
                          age: bedData?['age'] ?? 0,
                          gender: bedData?['gender'] ?? 'Unknown',
                          phoneNumber: bedData?['phoneNumber'] ?? 'Unknown',
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showDeleteConfirmationDialog(bed.id);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bed ${bedData?['bedNumber'] ?? 'Unknown'}",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: AppColors.primaryColor),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddBedDialog,
          backgroundColor: AppColors.primaryColor,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

// دالة عرض رسالة تأكيد الخروج
  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit?"),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // البقاء في التطبيق
                child: const Text("No",
                    style: TextStyle(color: AppColors.primaryColor)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // الخروج
                child: const Text("Yes",
                    style: TextStyle(color: AppColors.warningColor)),
              ),
            ],
          ),
        ) ??
        false; // القيمة الافتراضية إذا تم إغلاق النافذة بدون اختيار
  }
}
