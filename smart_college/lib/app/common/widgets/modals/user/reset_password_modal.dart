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
  const ResetPasswordModal({super.key});

  @override
  _ResetPasswordModalState createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends State<ResetPasswordModal> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final UserRepository _userRepository = UserRepository(client: HttpClient());
  late Future<UserModel> futureUser;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    futureUser = UserHelper.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Redefinir senha',
                  style: AppTextStyles.biggerText
                      .copyWith(color: AppColors.titlePurple),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Crie uma nova senha de acordo com nossos parâmetros',
                  style:
                      AppTextStyles.smallText.copyWith(color: AppColors.gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Nova Senha',
                  style:
                      AppTextStyles.smallText.copyWith(color: AppColors.gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return 'Por favor, digite sua nova senha';
                    }
                    return null;
                  },
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.gray,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Confirmar Senha',
                  style:
                      AppTextStyles.smallText.copyWith(color: AppColors.gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: _passwordConfirmController,
                  keyboardType: TextInputType.text,
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return 'Por favor, confirme sua nova senha';
                    } else if (password != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.gray,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon:
                  const Icon(Icons.help_outline_rounded, color: AppColors.gray),
              onPressed: _showPasswordPolicyAlert,
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordPolicyAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Política de Senha',
              style: AppTextStyles.mediumTextBold
                  .copyWith(color: AppColors.titlePurple),
                  textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('A senha deve conter:',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.inputText)),
                Text('- Pelo menos uma letra maiúscula',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
                Text('- Pelo menos um caractere especial',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
                Text('- Pelo menos 8 caracteres',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: AppTextStyles.smallerTextBold
                  .copyWith(color: AppColors.titlePurple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.invalidPassword);
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
        RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password);
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
        child: const ResetPasswordModal(),
      );
    },
  );
}