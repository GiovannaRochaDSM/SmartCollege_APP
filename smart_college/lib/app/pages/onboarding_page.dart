import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/login_page.dart';
import 'package:smart_college/app/pages/register_page.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_elevated_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPage createState() => _OnboardingPage();
}

class _OnboardingPage extends State<OnboardingPage> {
    @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding-background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 170),
                Text(
                  'SmartCollege',
                  style: AppNewTextStyles.bigBalooTitle.copyWith(color: AppNewColors.black),
                ),
                const SizedBox(height: 20),
                Text(
                  'seu app na organização',
                  style: AppNewTextStyles.mediumPoppinsRegular.copyWith(color: AppNewColors.black),
                ),
                const SizedBox(height: 30),
                Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 40),
                CustomElevatedButton(
                  text: 'Entrar',
                  buttonColor: AppNewColors.darkBlue,
                  textColor: AppNewColors.white,
                  borderColor: AppNewColors.darkBlue,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                CustomTextButton(
                  text: 'Criar uma conta',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
