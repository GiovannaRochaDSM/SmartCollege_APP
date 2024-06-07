import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const PrimaryButton({super.key, this.onPressed, required this.text});

  final BorderRadius _borderRadius =
      const BorderRadius.all(Radius.circular(42.0));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: _borderRadius,
      onTap: onPressed,
      child: Ink(
        height: 56.0,
        width: 290.0,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          border: Border.all(
            color: AppColors.pink,
            width: 1,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradient,
          ),
        ),
        child: Align(
          child: Text(
            text,
            style:
                AppTextStyles.smallText.copyWith(color: AppColors.textButton),
          ),
        ),
      ),
    );
  }
}
