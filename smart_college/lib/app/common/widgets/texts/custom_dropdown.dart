import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String labelText;
  final void Function(String?) onChanged;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.labelText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: AppTextStyles.smallerText.copyWith(color: AppColors.gray),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: AppTextStyles.smallerText.copyWith(color: AppColors.gray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: AppColors.purple),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.purple),
            borderRadius: BorderRadius.circular(20.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: AppColors.purple),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
      ),
    );
  }
}
