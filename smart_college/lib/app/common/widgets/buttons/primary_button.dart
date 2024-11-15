import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? textColor;
  final Color? buttonColor; 
  final Color? borderColor;

  const PrimaryButton({
    super.key,
    this.onPressed,
    required this.text,
    this.textColor,
    this.buttonColor,
    this.borderColor
  });

  final BorderRadius _borderRadius = const BorderRadius.all(Radius.circular(10.0));

  @override
  Widget build(BuildContext context) {
    final Color buttonBackgroundColor = buttonColor ?? AppNewColors.pink;
    final Color buttonTextColor = textColor ?? AppColors.white;
    final Color buttonBorderColor = borderColor ?? AppNewColors.pink;

    return InkWell(
      borderRadius: _borderRadius,
      onTap: onPressed,
      child: Ink(
        height: 49.0,
        width: 246.0,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          color: buttonBackgroundColor,
          border: Border.all(
            color: buttonBorderColor,
            width: 2,
          ),
        ),
        child: Align(
          child: Text(
            text,
            style: AppTextStyles.normalText.copyWith(
              color: buttonTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
