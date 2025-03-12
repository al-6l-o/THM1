import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Providers/theme_provider.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:lottie/lottie.dart';
import 'patient_info_dialogs.dart';
import 'patient_info_firebase.dart';
import 'patient_info_widgets.dart';

class PatientInfoScreen extends StatefulWidget {
  final String docId;
  final String bedNumber;
  final String bedName;
  final int age;
  final String gender;
  final String phoneNumber;
  final String doctorName;

  const PatientInfoScreen({
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
  PatientInfoScreenState createState() => PatientInfoScreenState();
}

class PatientInfoScreenState extends State<PatientInfoScreen> {
  late TextEditingController bedNumberController;
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController phoneController;
  late TextEditingController doctorNameController;

  bool _isEditing = false;
  bool _isError = false; // متغير لحالة الخطأ
  String _errorMessage = ''; // نص رسالة الخطأ

  late String originalBedNumber,
      originalName,
      originalAge,
      originalGender,
      originalPhone,
      originaldoctorName;

  late String selectedGender;
  int? patientId; // السماح بأن يكون `null` لمنع الخطأ
  late Future<int> loadPatientIdFuture; // تعريف المتغير

  @override
  void initState() {
    super.initState();
    loadPatientIdFuture = loadPatientId(); // تعيين دالة التحميل
    initializeControllers();
  }

  void initializeControllers() {
    bedNumberController = TextEditingController(text: widget.bedNumber);
    nameController = TextEditingController(text: widget.bedName);
    ageController = TextEditingController(text: widget.age.toString());
    phoneController = TextEditingController(text: widget.phoneNumber);
    doctorNameController = TextEditingController(text: widget.doctorName);

    selectedGender = widget.gender;

    originalBedNumber = widget.bedNumber;
    originalName = widget.bedName;
    originalAge = widget.age.toString();
    originalGender = widget.gender;
    originalPhone = widget.phoneNumber;
    originaldoctorName = widget.doctorName;
  }

  @override
  void dispose() {
    bedNumberController.dispose();
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    doctorNameController.dispose();

    super.dispose();
  }

  void _updatePatientData() async {
    var docRef =
        FirebaseFirestore.instance.collection('beds').doc(widget.docId);
    String newBedNumber = bedNumberController.text.trim();

    // التحقق مما إذا كان رقم السرير الجديد موجودًا بالفعل في قاعدة البيانات
    var querySnapshot = await FirebaseFirestore.instance
        .collection('beds')
        .where('bedNumber', isEqualTo: newBedNumber)
        .get();

    bool bedNumberExists =
        querySnapshot.docs.any((doc) => doc.id != widget.docId);

    if (bedNumberExists) {
      showDuplicateBedNumberDialog(context);
      return; // الخروج دون تحديث البيانات
    }

    // تحديث البيانات إذا لم يكن رقم السرير مكررًا
    docRef.get().then((docSnapshot) {
      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Document does not exist!')),
        );
        return;
      }

      docRef.update({
        'bedNumber': newBedNumber,
        'bedName': nameController.text.trim(),
        'age': int.tryParse(ageController.text) ?? int.parse(originalAge),
        'gender': selectedGender,
        'phoneNumber': phoneController.text.trim(),
        'doctorName': doctorNameController.text.trim(),
      }).then((_) {
        setState(() {
          _isEditing = false;
          originalBedNumber = newBedNumber;
          originalName = nameController.text;
          originalAge = ageController.text;
          originalGender = selectedGender;
          originalPhone = phoneController.text;
          originaldoctorName = doctorNameController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(S.of(context).updated_successfully,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color)),
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).update_failed}: $error')),
        );
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching document: $error')),
      );
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;

      bedNumberController.text = originalBedNumber;
      nameController.text = originalName;
      ageController.text = originalAge;
      selectedGender = originalGender;
      phoneController.text = originalPhone;
      doctorNameController.text = originaldoctorName;
    });
  }

  Future<bool> _onWillPop() async {
    if (_isEditing) {
      _cancelEditing();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).patient_informations,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          backgroundColor: AppColors.primaryColor,
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
// استخدم FutureBuilder لانتظار تحميل patientId
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('beds')
                      .doc(widget.docId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      );
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      // ✅ إذا تم حذف المريض، إغلاق الصفحة تلقائيًا
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddBedsScreen()), // استبدل `HomePage` بصفحتك الرئيسية
                            (Route<dynamic> route) => false,
                          );
                        }
                      });

                      return Center(
                        child: Text(
                          "Patient data not found.",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      var data = snapshot.data!;
                      int patientId = data['patientId'] ?? 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${S.of(context).patientId} : $patientId',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                  },
                ),
                _buildTextField(S.of(context).bed_number, bedNumberController,
                    originalValue: originalBedNumber),
                _buildTextField(S.of(context).name, nameController,
                    originalValue: originalName),
                _buildTextField(S.of(context).age, ageController,
                    isNumber: true, originalValue: originalAge),
                _buildGenderSelector(),
                _buildTextField(S.of(context).phone_number, phoneController,
                    originalValue: originalPhone),
                _buildTextField(S.of(context).doctor_name, doctorNameController,
                    originalValue: originaldoctorName),
                const SizedBox(height: 20),
                if (_isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _updatePatientData,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        child: Text(
                          S.of(context).save,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _cancelEditing,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error),
                        child: Text(
                          S.of(context).cancel,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (patientId != 0) {
                            // التحقق مما إذا كان `patientId` قد تم تحميله
                            showDeleteConfirmationDialog(context, widget.docId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Patient ID is not available yet.")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error),
                        child: Text(
                          S.of(context).delete,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showEditConfirmationDialog(() {
            setState(() {
              _isEditing = true;
            });
          }),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.edit,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, required String originalValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus && controller.text.trim().isEmpty) {
            setState(() {
              controller.text = originalValue; // إرجاع القيمة الأصلية
            });
          }
        },
        child: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          enabled: _isEditing,
          cursorColor:
              Theme.of(context).colorScheme.primary, // تغيير لون المؤشر
          decoration: InputDecoration(
              labelText: label,
              labelStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              )),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).gender,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.primary),
          ),
          Row(
            children: [
              Radio<String>(
                value: S.of(context).male,
                groupValue: selectedGender,
                onChanged: _isEditing
                    ? (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      }
                    : null,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              Text(S.of(context).male),
              Radio<String>(
                value: S.of(context).female,
                groupValue: selectedGender,
                onChanged: _isEditing
                    ? (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      }
                    : null,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              Text(S.of(context).female),
            ],
          ),
        ],
      ),
    );
  }
}
