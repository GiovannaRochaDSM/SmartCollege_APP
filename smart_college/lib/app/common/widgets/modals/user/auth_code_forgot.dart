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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'CÓDIGO DE AUTENTICAÇÃO - ESQUECI A SENHA' ,    
       style: AppTextStyles.smallTextBold.copyWith(color: AppColors.white),
      textAlign: TextAlign.right,
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple, AppColors.pink],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
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
                  'Insira o código enviado para no seu email para redefinir sua senha e voltar à se organizar conosco!',
                  style: AppTextStyles.smallText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
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
                const SizedBox(height: 40),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
