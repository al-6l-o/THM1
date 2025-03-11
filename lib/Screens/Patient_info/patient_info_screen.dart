import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Providers/theme_provider.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:lottie/lottie.dart';

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
  _PatientInfoScreenState createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  late TextEditingController _bedNumberController;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _doctorNameController;

  bool _isEditing = false;
  bool _isError = false; // متغير لحالة الخطأ
  String _errorMessage = ''; // نص رسالة الخطأ

  late String _originalBedNumber,
      _originalName,
      _originalAge,
      _originalGender,
      _originalPhone,
      _originaldoctorName;

  late String _selectedGender;
  int? _patientId; // السماح بأن يكون `null` لمنع الخطأ
  late Future<int> _loadPatientIdFuture; // تعريف المتغير

  @override
  void initState() {
    super.initState();
    _loadPatientIdFuture = _loadPatientId(); // تعيين دالة التحميل
    _initializeControllers();
  }

  Future<int> _loadPatientId() async {
    try {
      DocumentSnapshot counterDoc = await FirebaseFirestore.instance
          .collection('beds')
          .doc(widget.docId)
          .get();

      if (counterDoc.exists &&
          counterDoc.data() != null &&
          counterDoc['patientId'] != null) {
        return counterDoc['patientId']; // إرجاع `patientId` كرقم صحيح
      } else {
        return 0; // إذا لم يكن هناك `patientId`
      }
    } catch (e) {
      print('Error loading patientId: $e');
      return 0; // في حال حدوث خطأ
    }
  }
  // حذف المرضى

  void _initializeControllers() {
    _bedNumberController = TextEditingController(text: widget.bedNumber);
    _nameController = TextEditingController(text: widget.bedName);
    _ageController = TextEditingController(text: widget.age.toString());
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _doctorNameController = TextEditingController(text: widget.doctorName);

    _selectedGender = widget.gender;

    _originalBedNumber = widget.bedNumber;
    _originalName = widget.bedName;
    _originalAge = widget.age.toString();
    _originalGender = widget.gender;
    _originalPhone = widget.phoneNumber;
    _originaldoctorName = widget.doctorName;
  }

  @override
  void dispose() {
    _bedNumberController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _doctorNameController.dispose();

    super.dispose();
  }

  void _updatePatientData() async {
    var docRef =
        FirebaseFirestore.instance.collection('beds').doc(widget.docId);
    String newBedNumber = _bedNumberController.text.trim();

    // التحقق مما إذا كان رقم السرير الجديد موجودًا بالفعل في قاعدة البيانات
    var querySnapshot = await FirebaseFirestore.instance
        .collection('beds')
        .where('bedNumber', isEqualTo: newBedNumber)
        .get();

    bool bedNumberExists =
        querySnapshot.docs.any((doc) => doc.id != widget.docId);

    if (bedNumberExists) {
      _showDuplicateBedNumberDialog();
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
        'bedName': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? int.parse(_originalAge),
        'gender': _selectedGender,
        'phoneNumber': _phoneController.text.trim(),
        'doctorName': _doctorNameController.text.trim(),
      }).then((_) {
        setState(() {
          _isEditing = false;
          _originalBedNumber = newBedNumber;
          _originalName = _nameController.text;
          _originalAge = _ageController.text;
          _originalGender = _selectedGender;
          _originalPhone = _phoneController.text;
          _originaldoctorName = _doctorNameController.text;
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

// دالة لعرض التنبيه إذا كان رقم السرير مكررًا
  void _showDuplicateBedNumberDialog() {
    showDialog(
      context: context,
      builder: (context) {
        backgroundColor:
        Theme.of(context).dialogTheme.backgroundColor;

        return AlertDialog(
          title: Text(
            S.of(context).bed_exists,
            style: TextStyle(
                color: Theme.of(context).colorScheme.error, fontSize: 20),
          ),
          content: Text(
            S.of(context).enter_another_number,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق التنبيه
              },
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;

      _bedNumberController.text = _originalBedNumber;
      _nameController.text = _originalName;
      _ageController.text = _originalAge;
      _selectedGender = _originalGender;
      _phoneController.text = _originalPhone;
      _doctorNameController.text = _originaldoctorName;
    });
  }

  Future<bool> _onWillPop() async {
    if (_isEditing) {
      _cancelEditing();
      return false;
    }
    return true;
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        bool isError = false;
        String errorMessage = "";
        bool isEditing = false; // يتحكم في تفعيل التعديل
        TextEditingController codeController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                S.of(context).confirm_modification_title,
                style: TextStyle(
                    fontSize: 18, color: Theme.of(context).primaryColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: S.of(context).confirm_modification_content,
                      labelStyle: TextStyle(fontSize: 14),
                      errorText: isError
                          ? errorMessage
                          : null, // يظهر الخطأ فقط عند الضغط على تأكيد
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (codeController.text == "1234") {
                      Navigator.of(context).pop(true); // إرجاع true عند النجاح
                    } else {
                      setState(() {
                        isError = true;
                        errorMessage = S.of(context).message_incorrect_number;
                      });
                    }
                  },
                  child: Text(S.of(context).Confirm),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    S.of(context).cancel,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((isVerified) {
      if (isVerified == true) {
        setState(() {
          _isEditing = true; // تفعيل التعديل بعد إغلاق الـ Dialog بنجاح
        });
      }
    });
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
                _buildTextField(S.of(context).bed_number, _bedNumberController,
                    originalValue: _originalBedNumber),
                _buildTextField(S.of(context).name, _nameController,
                    originalValue: _originalName),
                _buildTextField(S.of(context).age, _ageController,
                    isNumber: true, originalValue: _originalAge),
                _buildGenderSelector(),
                _buildTextField(S.of(context).phone_number, _phoneController,
                    originalValue: _originalPhone),
                _buildTextField(
                    S.of(context).doctor_name, _doctorNameController,
                    originalValue: _originaldoctorName),
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
                          if (_patientId != 0) {
                            // التحقق مما إذا كان `patientId` قد تم تحميله
                            _showDeleteConfirmationDialog(
                                context, widget.docId.toString());
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
          onPressed: _showEditDialog,
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
                groupValue: _selectedGender,
                onChanged: _isEditing
                    ? (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      }
                    : null,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              Text(S.of(context).male),
              Radio<String>(
                value: S.of(context).female,
                groupValue: _selectedGender,
                onChanged: _isEditing
                    ? (value) {
                        setState(() {
                          _selectedGender = value!;
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

  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/warning.json', // مسار الأنيميشن
                width: 75,
                height: 75,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).confirm_deleted_bed,
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // إغلاق النافذة
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                _deletePatient(context, docId); // استدعاء دالة الحذف
                Navigator.of(context).pop(); // إغلاق النافذة بعد الحذف
              },
              child: Text(
                S.of(context).delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePatient(BuildContext context, String docId) async {
    try {
      DocumentSnapshot patientDoc =
          await FirebaseFirestore.instance.collection('beds').doc(docId).get();

      if (patientDoc.exists) {
        Map<String, dynamic> patientData =
            patientDoc.data() as Map<String, dynamic>;
        patientData['deletedAt'] = FieldValue.serverTimestamp(); // تاريخ الحذف

        // ✅ نقل البيانات إلى مجموعة `deleted_patients`
        await FirebaseFirestore.instance
            .collection('previous patients')
            .doc(docId)
            .set(patientData);

        // ✅ حذف المستند من `beds` بعد النسخ
        await FirebaseFirestore.instance.collection('beds').doc(docId).delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Patient moved to archive!")),
          );

          // ✅ العودة للصفحة الرئيسية
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddBedsScreen()), // استبدل `HomePage` بصفحتك الرئيسية
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print("❌ Patient data not found!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Patient not found!")),
        );
      }
    } catch (error) {
      print('❌ Failed to delete patient: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to move patient to archive!")),
        );
      }
    }
  }
}
