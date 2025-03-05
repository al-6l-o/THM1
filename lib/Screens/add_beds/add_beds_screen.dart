import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:t_h_m/Screens/vital_signs/vital_signs_screen.dart';
import 'package:t_h_m/Screens/settings/settings_screen.dart';
import 'package:t_h_m/Providers/theme_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:t_h_m/generated/l10n.dart';

class AddBedsScreen extends StatefulWidget {
  @override
  _AddBedsScreenState createState() => _AddBedsScreenState();
}

class _AddBedsScreenState extends State<AddBedsScreen> {
  static const int maxBeds = 10; // الحد الأقصى لعدد الأسرة

  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String patientId = '';
  String doctorName = '';
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
                S.of(context).added_successfully,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // النص المترجم
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteBed(String bedId) {
    FirebaseFirestore.instance.collection('beds').doc(bedId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(S.of(context).deleted_successfully,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color)),
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor),
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
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          // خلفية المربع الحواري
          contentPadding: EdgeInsets.all(20),
          content: Stack(
            clipBehavior: Clip.none, // يسمح بظهور الأنيميشن خارج الـ Box
            children: [
              Positioned(
                top: -65, // اجعل الأنيميشن يظهر فوق البوكس
                left: 80,
                child: Lottie.asset(
                  'assets/animations/warning.json', // ضع مسار الأنيميشن هنا
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                S.of(context).confirm_deleted_bed,
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق النافذة
              },
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteBed(bedId); // استدعاء دالة الحذف
                Navigator.of(context).pop(); // إغلاق النافذة بعد الحذف
              },
              child: Text(S.of(context).delet,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
      labelStyle:
          TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
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
          content: Text(S.of(context).maximum_beds_reached),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return; // الخروج من الدالة وعدم فتح نافذة الإضافة
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).add_patient),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration:
                            customInputDecoration(S.of(context).patient_id),
                        cursorColor: Theme.of(context).colorScheme.primary,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                        validator: (value) =>
                            value!.isEmpty ? S.of(context).please_id : null,
                        onSaved: (value) => bedName = value!,
                      ),
                      TextFormField(
                        decoration:
                            customInputDecoration(S.of(context).bed_number),
                        keyboardType: TextInputType.number,
                        cursorColor: Theme.of(context).colorScheme.primary,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return S.of(context).please_bed_number;
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
                        decoration: customInputDecoration(S.of(context).name),
                        cursorColor: Theme.of(context).colorScheme.primary,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                        validator: (value) =>
                            value!.isEmpty ? S.of(context).please_name : null,
                        onSaved: (value) => bedName = value!,
                      ),
                      TextFormField(
                        decoration: customInputDecoration(S.of(context).age),
                        keyboardType: TextInputType.number,
                        cursorColor: Theme.of(context).colorScheme.primary,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                        validator: (value) =>
                            value!.isEmpty ? S.of(context).please_age : null,
                        onSaved: (value) => age = value!,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.of(context).gender),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: S.of(context).male,
                                      groupValue: gender,
                                      onChanged: (value) {
                                        setState(() {
                                          gender = value!;
                                        });
                                      },
                                      activeColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    Text(S.of(context).male),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: S.of(context).female,
                                      groupValue: gender,
                                      onChanged: (value) {
                                        setState(() {
                                          gender = value!;
                                        });
                                      },
                                      activeColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    Text(S.of(context).female),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        decoration:
                            customInputDecoration(S.of(context).phone_number)
                                .copyWith(
                          prefixText: S.of(context).pre,
                          prefixStyle: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
                        ),
                        keyboardType: TextInputType.phone,
                        cursorColor: Theme.of(context).colorScheme.primary,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).please_phone;
                          }
                          if (value.length != 9) {
                            return S.of(context).phone_9;
                          }
                          return null;
                        },
                        onSaved: (value) => phoneNumber = value!,
                      ),
                      TextFormField(
                        decoration:
                            customInputDecoration(S.of(context).doctor_name),
                        cursorColor: Theme.of(context).colorScheme.primary,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                        validator: (value) => value!.isEmpty
                            ? S.of(context).please_doctor_name
                            : null,
                        onSaved: (value) => bedName = value!,
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
              child: Text(S.of(context).cancel,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  )),
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
                      errorMessage = S.of(context).bed_exists;
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
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(S.of(context).add,
                  style: TextStyle(color: Colors.white)),
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
                      color: Theme.of(context).colorScheme.background,
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
                              "${S.of(context).bed} ${bedData?['bedNumber'] ?? 'Unknown'}",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.onBackground)
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
          child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

// دالة عرض رسالة تأكيد الخروج
  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            title: Text(
              S.of(context).exit_app,
              style: TextStyle(fontSize: 17),
            ),
            content: Text(
              S.of(context).confirm_exit,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // البقاء في التطبيق
                child: Text(S.of(context).no,
                    style: TextStyle(color: AppColors.primaryColor)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // الخروج
                child: Text(S.of(context).yes,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        ) ??
        false; // القيمة الافتراضية إذا تم إغلاق النافذة بدون اختيار
  }
}
