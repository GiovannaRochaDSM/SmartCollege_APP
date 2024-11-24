import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppNewColors.textGray),
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0.0)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppNewColors.lightGray,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        hintText: 'Digite aqui',
        hintStyle: AppNewTextStyles.smallExtraLight.copyWith(color: AppNewColors.textGray),
        alignLabelWithHint: true,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        labelStyle: AppNewTextStyles.smallExtraLight.copyWith(color: AppNewColors.textGray),
      ),
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
    );
  }
}
