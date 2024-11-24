import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        style: AppNewTextStyles.mediumPoppinsRegular.copyWith(color: AppNewColors.mediumGray),
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          filled: true,
          fillColor: Colors.grey[200],
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppNewColors.lightGray),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppNewColors.lightGray),
            borderRadius: BorderRadius.zero,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppNewColors.lightGray),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 20.0),
        ),
      ),
    );
  }
}
