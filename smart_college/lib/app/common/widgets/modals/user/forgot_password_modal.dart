import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/user_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';
import 'package:smart_college/app/common/widgets/modals/user/auth_code_forgot.dart';

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
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Esqueceu a senha?',
              style: AppTextStyles.biggerText
                  .copyWith(color: AppColors.titlePurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            Text(
              'Digite seu e-mail cadastrado aqui na plataforma, vamos te ajudar a recuperar sua senha.',
              style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              'E-MAIL',
              style: AppTextStyles.normalText.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (email) {
                  if (email == null || email.isEmpty) {
                    return 'Por favor, digite seu e-mail';
                  } else if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(email)) {
                    return 'Por favor, digite um e-mail correto';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelStyle:
                      AppTextStyles.smallerText.copyWith(color: AppColors.gray),
                  prefixIcon:
                      const Icon(Icons.email_rounded, color: AppColors.purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: AppColors.gray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: AppColors.gray),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 20.0),
                ),
              ),
            ),
            const SizedBox(height: 70),
            PrimaryButton(
              text: 'Enviar',
              onPressed: () {
                _resetPassword(context);
              },
            ),
            const SizedBox(height: 5),
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

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.emailResetPasswordError);
      return;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
          ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.emailResetPasswordInvalid);
      return;
    }
    
    try {
      await _userRepository.forgotPassword(email);
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.emailSendCodeResetPasswordSuccess);
      Navigator.of(context).pop();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AuthCodeForgotModal()));
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
        child: const ForgotPasswordModal(),
      );
    },
  );
}
