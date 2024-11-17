import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double? height;
  final Color? textColor;
  final Color? buttonColor;
  final Color? borderColor;

  const CustomElevatedButton({
    super.key,
    this.onPressed,
    required this.text,
    this.textColor,
    this.buttonColor,
    this.borderColor,
    this.width,
    this.height,
  });

  final BorderRadius _borderRadius = const BorderRadius.all(Radius.circular(10.0));

  @override
  Widget build(BuildContext context) {
    final Color buttonBackgroundColor = buttonColor ?? AppNewColors.pink;
    final Color buttonTextColor = textColor ?? AppColors.white;
    final Color buttonBorderColor = borderColor ?? AppNewColors.pink;
    final double buttonWidth = width ?? 246.0;
    final double buttonHeight = height ?? 49.0;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: buttonTextColor,
        backgroundColor: buttonBackgroundColor,
        side: BorderSide(color: buttonBorderColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: _borderRadius, 
        ),
        minimumSize: Size(buttonWidth, buttonHeight),
      ),
      child: Text(
        text,
        style: AppNewTextStyles.mediumExtraLight.copyWith(
          color: buttonTextColor,
        ),
      ),
    );
  }
}

