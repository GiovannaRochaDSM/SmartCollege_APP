import 'package:flutter/material.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_form_field.dart';
import 'package:smart_college/app/pages/register_page.dart';
import 'package:smart_college/app/pages/subject_screen.dart';
import 'package:smart_college/app/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_button.dart';
import 'package:smart_college/app/common/widgets/modals/user/forgot_password_modal.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Form(
        key: _formkey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'É bom te ver novamente!',
                  style: AppTextStyles.mediumTextBold
                      .copyWith(color: AppColors.titlePurple),
                ),
                const SizedBox(height: 20),
                Text(
                  'LOGIN',
                  style:
                      AppTextStyles.smallText.copyWith(color: AppColors.gray),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 300,
                  child: CustomTextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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
                ),
                const SizedBox(height: 20),
                Text(
                  'SENHA',
                  style:
                      AppTextStyles.smallText.copyWith(color: AppColors.gray),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 300,
                  child: CustomTextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    validator: (senha) {
                      if (senha == null || senha.isEmpty) {
                        return 'Por favor, digite sua senha';
                        // TO DO: Adicionar políticas de senha
                      } else if (senha.length < 2) {
                        return 'Por favor, digite uma senha maior que 6 caracteres';
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
                ),
                const SizedBox(height: 1),
                CustomTextButton(
                  text: 'Esqueci minha senha',
                  onPressed: () {
                    _showForgotPasswordModal(context);
                  },
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: 'Entrar',
                  onPressed: () async {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (_formkey.currentState!.validate()) {
                      bool isLogged = await AuthService.login(
                          _emailController.text, _passwordController.text);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (isLogged) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubjectPage(),
                          ),
                        );
                      } else {
                        _passwordController.clear();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(AppSnackBar.invalidEmailOrPassword);
                      }
                    }
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  'Ainda não possui uma conta?',
                  style:
                      AppTextStyles.smallerText.copyWith(color: AppColors.gray),
                ),
                CustomTextButton(
                  text: 'Cadastre-se aqui',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ForgotPasswordModal();
      },
    ).then((result) {
      if (result != null && result is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    });
  }
}
