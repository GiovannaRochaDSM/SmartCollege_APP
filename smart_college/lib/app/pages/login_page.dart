import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/register_page.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/modals/user/auth_code.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.gray),
            onPressed: _showPasswordPolicyAlert,
          ),
        ],
      ),
      body: Form(
        key: _formkey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 1),
                Text(
                  'É bom te ver novamente!',
                  style: AppTextStyles.biggerText
                      .copyWith(color: AppColors.titlePurple),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'E-MAIL',
                  style:
                      AppTextStyles.normalText.copyWith(color: AppColors.gray),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      labelStyle: AppTextStyles.smallerText
                          .copyWith(color: AppColors.gray),
                      prefixIcon: const Icon(Icons.email_rounded,
                          color: AppColors.purple),
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
                const SizedBox(height: 20),
                Text(
                  'SENHA',
                  style:
                      AppTextStyles.normalText.copyWith(color: AppColors.gray),
                ),
                const SizedBox(height: 5),
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return 'Por favor, digite sua senha';
                    } else if (password.length < 8) {
                      return 'Por favor, digite uma senha válida';
                    } else if (!RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,}$')
                        .hasMatch(password)) {
                      return 'Por favor, digite uma senha válida';
                    }
                    return null;
                  },
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelStyle: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray),
                    prefixIcon: const Icon(Icons.key, color: AppColors.purple),
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
                        color: AppColors.purple,
                      ),
                    ),
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
                const SizedBox(height: 1),
                CustomTextButton(
                  text: 'Esqueci minha senha',
                  onPressed: () {
                    _showForgotPasswordModal(context);
                  },
                ),
                const SizedBox(height: 20),
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
                            builder: (context) => const AuthCodeModal(),
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
                      AppTextStyles.smallText.copyWith(color: AppColors.gray),
                ),
                CustomTextButton(
                  text: 'Cadastre-se aqui',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()));
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
        return const ForgotPasswordModal();
      },
    ).then((result) {
      if (result != null && result is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    });
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
}
