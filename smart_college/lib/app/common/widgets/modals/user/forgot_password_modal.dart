import 'package:flutter/material.dart';
import 'package:smart_college/app/common/widgets/modals/user/auth_code_forgot.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/user_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_form_field.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';

class ForgotPasswordModal extends StatefulWidget {
  @override
  _ForgotPasswordModalState createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final TextEditingController _emailController = TextEditingController();
  final UserRepository _userRepository = UserRepository(client: HttpClient());

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Recuperar Senha',
              style: AppTextStyles.bigText.copyWith(color: AppColors.titlePurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Digite seu e-mail cadastrado aqui na plataforma, vamos te ajudar a recuperar sua senha.',
              style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              'E-mail',
              style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              validator: (email) {
                if (email == null || email.isEmpty) {
                  return 'Por favor, digite seu e-mail';
                } else if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(_emailController.text)) {
                  return 'Por favor, digite um e-mail correto';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              text: 'Enviar',
              onPressed: () {
                _resetPassword(context);
              },
            ),
            const SizedBox(height: 10),
            CustomTextButton(
              text: 'Cancelar',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _resetPassword(BuildContext context) async {
    final email = _emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.emailResetPasswordError);
      return;
    }

    try {
      await _userRepository.forgotPassword(email);
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.emailSendCodeResetPasswordSuccess);
      Navigator.of(context).pop();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AuthCodeForgotPage()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.emailSendCodeResetPasswordError);
    }
  }
}

void showForgotPasswordModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ForgotPasswordModal(),
      );
    },
  );
}
