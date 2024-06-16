import 'package:flutter/material.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/pages/task_page.dart';
import 'package:smart_college/app/services/auth_service.dart';

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
        title: const Text('Código de Autenticação'),
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
                  'Insira o código de autenticação enviado para o seu e-mail',
                  style: AppTextStyles.mediumText,
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
                      bool isValid = await AuthService.validateAuthCode(
                          _authCodeController.text);
                      if (isValid) {
                        String? token = await AuthService.getToken();
                        if (token != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TaskPage(),
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
