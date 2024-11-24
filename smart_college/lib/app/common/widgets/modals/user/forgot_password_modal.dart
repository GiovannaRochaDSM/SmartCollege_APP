import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/user_repository.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_form_field.dart';
import 'package:smart_college/app/common/widgets/modals/user/auth_code_forgot.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_primary_button.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  @override
  _ForgotPasswordModalState createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final TextEditingController _emailController = TextEditingController();
  final UserRepository _userRepository = UserRepository(client: HttpClient());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppNewColors.lightBlue,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Esqueceu a senha?',
                style: AppNewTextStyles.bigBalooTitle.copyWith(color: AppNewColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'Digite seu e-mail cadastrado aqui na plataforma, vamos te ajudar a recuperar sua senha.',
                style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                'E-mail',
                style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CustomTextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return 'Por favor, digite seu e-mail';
                    } else if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
                      return 'Por favor, digite um e-mail correto';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(Icons.email_rounded, color: AppNewColors.darkGray),
                ),
              ),
              const SizedBox(height: 90),
              CustomPrimaryButton(
                text: 'Enviar',
                onPressed: () {
                  _resetPassword(context);
                },
                buttonColor: AppNewColors.white,
                borderColor: AppNewColors.white,
                textColor: AppNewColors.darkBlue,
              ),
              const SizedBox(height: 10),
              CustomTextButton(
                text: 'Cancelar',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                textColor: AppNewColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetPassword(BuildContext context) async {
    final email = _emailController.text;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.emailResetPasswordError);
      return;
    } else if (!RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
          ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.emailResetPasswordInvalid);
      return;
    }
    
    try {
      await _userRepository.forgotPassword(email);

      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.emailSendCodeResetPasswordSuccess);

      Navigator.of(context).pop();

      _showAuthCodeForgotModal(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.emailSendCodeResetPasswordError);
    }
  }
}

void _showAuthCodeForgotModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            color: Colors.white,
            constraints: const BoxConstraints(maxHeight: 600),
            child: const AuthCodeForgotModal(),
          ),
        );
      },
    ).then((result) {
      if (result != null && result is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)),
        );
      }
    });
}
