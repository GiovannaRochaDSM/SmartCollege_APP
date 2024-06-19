import 'package:flutter/material.dart';
import 'package:smart_college/app/services/auth_service.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/modals/user/reset_password_modal.dart';


class AuthCodeForgotPage extends StatefulWidget {
  const AuthCodeForgotPage({Key? key}) : super(key: key);

  @override
  _AuthCodePageForgotState createState() => _AuthCodePageForgotState();
}

class _AuthCodePageForgotState extends State<AuthCodeForgotPage> {
  final _formKey = GlobalKey<FormState>();
  final _authCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Código de Autenticação - Esqueci a Senha'),
        backgroundColor: AppColors.gray,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'ESQUECI A SENHA',
                  style: AppTextStyles.normalText,
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Insira o código enviado para autenticação e redefinição de senha.',
                  style: AppTextStyles.smallText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _authCodeController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o código';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Código de Autenticação',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: 'Validar',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
