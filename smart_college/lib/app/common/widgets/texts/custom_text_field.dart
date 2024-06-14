import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: AppTextStyles.smallerText.copyWith(color: AppColors.inputText),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: AppTextStyles.smallerText.copyWith(color: AppColors.inputText),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black54),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.lightBlack),
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
      ),
    );
  }
}
