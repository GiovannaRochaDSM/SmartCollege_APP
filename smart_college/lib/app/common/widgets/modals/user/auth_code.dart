import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/home_page.dart';
import 'package:smart_college/app/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';

class AuthCodePage extends StatefulWidget {
  const AuthCodePage({Key? key}) : super(key: key);

  @override
  _AuthCodePageState createState() => _AuthCodePageState();
}

class _AuthCodePageState extends State<AuthCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _authCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
    title: Text(
      'CÓDIGO DE AUTENTICAÇÃO',
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
                  'Insira o código enviado para no seu email para autenticar e se organizar conosco!',
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
                      bool isValid = await AuthService.validateAuthCode(
                          _authCodeController.text);
                      if (isValid) {
                        String? token = await AuthService.getToken();
                        if (token != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
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
