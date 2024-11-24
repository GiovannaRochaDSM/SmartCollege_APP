import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/home_page.dart';
import 'package:smart_college/app/pages/onboarding_page.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_form_field.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_primary_button.dart';

class AuthCodeModal extends StatefulWidget {
  const AuthCodeModal({super.key});

  @override
  _AuthCodeModalState createState() => _AuthCodeModalState();
}

class _AuthCodeModalState extends State<AuthCodeModal> {
  final _formKey = GlobalKey<FormState>();
  final _authCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppNewColors.darkBlue,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 10),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Código de autenticação',
                      style: AppNewTextStyles.bigBalooTitle.copyWith(color: AppNewColors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Insira o código enviado para no seu email para autenticar e se organizar conosco!',
                      style: AppNewTextStyles.smallExtraLight.copyWith(color: AppNewColors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 240,
                      child: CustomTextFormField(
                        controller: _authCodeController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o código';
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.key, color: AppNewColors.darkGray),
                      ),
                    ),
                    const SizedBox(height: 100),
                    CustomPrimaryButton(
                      borderColor: AppNewColors.white,
                      buttonColor: AppNewColors.white,
                      textColor: AppNewColors.darkBlue,
                      text: 'Este é o código',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          bool isValid = await AuthService.validateAuthCode(_authCodeController.text);
                          if (isValid) {
                            String? token = await AuthService.getToken();
                            if (token != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.error);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.invalidAuthCode);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextButton(
                      text: 'Cancelar',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage(),
                          ),
                        );
                      },
                      textColor: AppNewColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
