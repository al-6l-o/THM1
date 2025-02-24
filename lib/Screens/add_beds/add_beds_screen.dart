import 'package:flutter/material.dart';
import 'package:t_h_m/Constants/colors.dart';

class AddBedsScreen extends StatefulWidget {
  @override
  _AddBedsScreenState createState() => _AddBedsScreenState();
}

class _AddBedsScreenState extends State<AddBedsScreen> {
  final _formKey = GlobalKey<FormState>();
  String bedName = '';
  String bedType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Bed'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Bed Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bed name';
                  }
                  return null;
                },
                onSaved: (value) {
                  bedName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bed Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bed type';
                  }
                  return null;
                },
                onSaved: (value) {
                  bedType = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // هنا يمكنك إضافة الكود لحفظ البيانات
                    print('Bed Name: $bedName, Bed Type: $bedType');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                ),
                child: Text(
                  'Add Bed',
                  style: TextStyle(color: AppColors.textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
