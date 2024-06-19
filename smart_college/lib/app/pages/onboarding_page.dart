import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/login_page.dart';
import 'package:smart_college/app/pages/register_page.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';

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
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SmartCollege',
                style: AppTextStyles.bigText
                    .copyWith(color: AppColors.titlePurple),
              ),
              const SizedBox(height: 20),
              Text(
                'Sua rotina de estudos de forma simples.',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.png',
                width: 147,
                height: 147,
              ),
              const SizedBox(height: 20),
              Text(
                'Ainda não possui uma conta?',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PrimaryButton(
                  text: 'Cadastre-se',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Já se organiza conosco?',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PrimaryButton(
                  text: 'Entre',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
