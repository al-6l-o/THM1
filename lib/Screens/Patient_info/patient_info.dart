import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Constants/colors.dart';

class PatientInfoScreen extends StatefulWidget {
  final String docId;
  final String bedNumber;
  final String bedName;
  final int age;
  final String gender;
  final String phoneNumber;

  const PatientInfoScreen({
    Key? key,
    required this.docId,
    required this.bedNumber,
    required this.bedName,
    required this.age,
    required this.gender,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _PatientInfoScreenState createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  late TextEditingController _bedNumberController;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  late String _originalBedNumber,
      _originalName,
      _originalAge,
      _originalGender,
      _originalPhone;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _bedNumberController = TextEditingController(text: widget.bedNumber);
    _nameController = TextEditingController(text: widget.bedName);
    _ageController = TextEditingController(text: widget.age.toString());
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _selectedGender = widget.gender;

    _originalBedNumber = widget.bedNumber;
    _originalName = widget.bedName;
    _originalAge = widget.age.toString();
    _originalGender = widget.gender;
    _originalPhone = widget.phoneNumber;
  }

  @override
  void dispose() {
    _bedNumberController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
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
      }).then((_) {
        setState(() {
          _isEditing = false;
          _originalBedNumber = newBedNumber;
          _originalName = _nameController.text;
          _originalAge = _ageController.text;
          _originalGender = _selectedGender;
          _originalPhone = _phoneController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated successfully!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $error')),
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
        return AlertDialog(
          title: const Text(
            "Bed Number Existed !",
            style: TextStyle(color: AppColors.warningColor, fontSize: 20),
          ),
          content: const Text(
            ' Please Enter Another Number',
            style: TextStyle(color: AppColors.textColor, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق التنبيه
              },
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.primaryColor),
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
          title: const Text('Patient informatins',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Bed Number', _bedNumberController,
                    originalValue: _originalBedNumber),
                _buildTextField('Name', _nameController,
                    originalValue: _originalName),
                _buildTextField('Age', _ageController,
                    isNumber: true, originalValue: _originalAge),
                _buildGenderSelector(),
                _buildTextField('Phone', _phoneController,
                    originalValue: _originalPhone),
                const SizedBox(height: 20),
                if (_isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _updatePatientData,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: AppColors.backgroundColor),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _cancelEditing,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warningColor),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.backgroundColor),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.edit, color: Colors.white),
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
          cursorColor: AppColors.primaryColor, // تغيير لون المؤشر
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.primaryColor),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: AppColors.primaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
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
          const Text(
            'Gender',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'Male',
                groupValue: _selectedGender,
                onChanged: _isEditing
                    ? (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      }
                    : null,
                activeColor: AppColors.primaryColor,
              ),
              const Text('Male'),
              Radio<String>(
                value: 'Female',
                groupValue: _selectedGender,
                onChanged: _isEditing
                    ? (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      }
                    : null,
                activeColor: AppColors.primaryColor,
              ),
              const Text('Female'),
            ],
          ),
        ],
      ),
    );
  }
}
