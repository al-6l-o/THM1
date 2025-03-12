import 'package:flutter/material.dart';
import 'package:t_h_m/generated/l10n.dart';

class PatientInfoWidgets {
  static Widget buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    required bool enabled,
    required String originalValue,
    required Function(String) onValueRestored,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus && controller.text.trim().isEmpty) {
            onValueRestored(originalValue);
          }
        },
        child: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          enabled: enabled,
          cursorColor: Theme.of(context).colorScheme.primary,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  static Widget buildGenderSelector({
    required BuildContext context,
    required bool enabled,
    required String selectedGender,
    required Function(String) onGenderSelected,
  }) {
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
                onChanged: enabled
                    ? (value) {
                        onGenderSelected(value!);
                      }
                    : null,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              Text(S.of(context).male),
              Radio<String>(
                value: S.of(context).female,
                groupValue: selectedGender,
                onChanged: enabled
                    ? (value) {
                        onGenderSelected(value!);
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
