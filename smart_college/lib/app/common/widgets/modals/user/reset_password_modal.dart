import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/login_page.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/user_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_form_field.dart';

class ResetPasswordModal extends StatefulWidget {
  @override
  _ResetPasswordModalState createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends State<ResetPasswordModal> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final UserRepository _userRepository = UserRepository(client: HttpClient());
  late Future<UserModel> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = UserHelper.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Redefinir Senha',
              style: AppTextStyles.bigText.copyWith(color: AppColors.titlePurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Crie uma nova senha de acordo com nossos parâmetros',
              style: AppTextStyles.smallerText.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Nova Senha',
              style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: _passwordController,
              keyboardType: TextInputType.text,
              obscureText: true,
              validator: (password) {
                if (password == null || password.isEmpty) {
                  return 'Por favor, digite sua nova senha';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Confirmar Senha',
              style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: _passwordConfirmController,
              keyboardType: TextInputType.text,
              obscureText: true,
              validator: (password) {
                if (password == null || password.isEmpty) {
                  return 'Por favor, confirme sua nova senha';
                } else if (password != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              text: 'Alterar',
              onPressed: () {
                _changePassword(context);
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

  void _changePassword(BuildContext context) async {
    final password = _passwordController.text;
    final confirmPassword = _passwordConfirmController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.fillFields);
      return;
    }

    if (!_validatePassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.invalidEmailOrPassword);
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.differentPasswordsFields);
      return;
    }

    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');
      UserModel currentUser = await futureUser;
      await _userRepository.resetPassword(token!, currentUser.email, password);
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.passwordUpdatedSuccess);
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.passwordUpdatedError);
    }
  }

  bool _validatePassword(String password) {
    return password.length >= 8 &&
        RegExp(r'(?=.*[A-Z])(?=.*[!@#\$&*~]).*$').hasMatch(password);
  }
}

void showResetPasswordModal(BuildContext context) {
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
        child: ResetPasswordModal(),
      );
    },
  );
}