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
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_form_field.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_primary_button.dart';

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
    return Scaffold(
      backgroundColor: AppNewColors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Redefinir senha',
                        style: AppNewTextStyles.bigBalooTitle.copyWith(color: AppNewColors.lightBlue),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Crie uma nova senha de acordo com nossos parâmetros',
                        style: AppNewTextStyles.smallExtraLight.copyWith(color: AppNewColors.textGray),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Nova Senha',
                        style: AppNewTextStyles.mediumExtraLight.copyWith(color: AppNewColors.textGray),
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
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: AppNewColors.darkGray,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Confirmar Senha',
                        style: AppNewTextStyles.mediumExtraLight.copyWith(color: AppNewColors.textGray),
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
                            _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: AppNewColors.darkGray,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      CustomPrimaryButton(
                        text: 'Alterar',
                        onPressed: () {
                          _changePassword(context);
                        },
                        textColor: AppNewColors.white,
                        borderColor: AppNewColors.lightBlue,
                        buttonColor: AppNewColors.lightBlue,
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
              ],
            ),
            Positioned(
              top: 50,
              right: 18,
              child: IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: AppNewColors.darkGray),
                onPressed: _showPasswordPolicyAlert,
                iconSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordPolicyAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppNewColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: Text(
            'Política de Senha',
            style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.lightBlue), 
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('A senha deve conter:',
                  style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray)),
                Text('- Pelo menos uma letra maiúscula',
                  style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray)),
                Text('- Pelo menos um caractere especial',
                  style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray)),
                Text('- Pelo menos 8 caracteres',
                  style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                side: const BorderSide(
                  color: AppNewColors.lightBlue,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('OK', style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.lightBlue)),
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
