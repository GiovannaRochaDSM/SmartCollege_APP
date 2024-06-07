import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.inputText),
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppColors.filledTextField,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        hintText: 'Digite aqui',
        hintStyle: const TextStyle(color: AppColors.gray),
        alignLabelWithHint: true,
        suffixIcon: suffixIcon,
      ),
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
    );
  }
}
