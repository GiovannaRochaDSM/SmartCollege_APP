import 'package:flutter/material.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/common/widgets/modals/user/reset_password_modal.dart';
import 'package:smart_college/app/pages/onboarding_page.dart';

class AuthCodeForgotModal extends StatefulWidget {
  const AuthCodeForgotModal({super.key});

  @override
  _AuthCodeModalForgotState createState() => _AuthCodeModalForgotState();
}

class _AuthCodeModalForgotState extends State<AuthCodeForgotModal> {
  final _formKey = GlobalKey<FormState>();
  final _authCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Código de autenticação',
                  style: AppTextStyles.biggerText
                      .copyWith(color: AppColors.titlePurple),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Text(
                  'Insira o código enviado para no seu   e-mail para redefinir sua senha e voltar à se organizar conosco!',
                  style:
                      AppTextStyles.smallText.copyWith(color: AppColors.gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 80),
                TextFormField(
                  controller: _authCodeController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o código';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Código de Autenticação',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: AppColors.gray),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
                PrimaryButton(
                  text: 'Este é o código',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool isValid = await AuthService.validateForgotCode(
                          _authCodeController.text);
                      if (isValid) {
                        String? token = await AuthService.getToken();
                        if (token != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPasswordModal(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            AppSnackBar.error,
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(AppSnackBar.invalidAuthCode);
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
