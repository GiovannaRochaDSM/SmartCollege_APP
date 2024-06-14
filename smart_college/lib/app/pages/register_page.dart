import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_form_field.dart';
import 'package:smart_college/app/pages/login_page.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smart_college/app/pages/onboarding_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _studentRecordController =
      TextEditingController(); // Novo campo
  final TextEditingController _nicknameController = TextEditingController();
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String studentRecord =
        _studentRecordController.text.trim(); // Novo campo
    final String nickname = _nicknameController.text.trim(); // Novo campo

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        studentRecord.isEmpty ||
        nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.fillFields);
      return;
    }

    String? base64Image;
    if (_imageFile != null) {
      final resizedImage =
          await _resizeImage(_imageFile!, maxWidth: 800, maxHeight: 600);
      List<int> imageBytes = resizedImage.readAsBytesSync();
      base64Image = base64Encode(imageBytes);
    }

    final Map<String, dynamic> requestData = {
      'name': name,
      'email': email,
      'password': password,
      'studentRecord': studentRecord, // Novo campo
      'nickname': nickname, // Novo campo
    };

    if (base64Image != null) {
      requestData['photo'] = base64Image;
    }

    final Uri uri = Uri.parse(AppRoutes.register);
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.userAddSuccess);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.userAddError);
    }
  }

  Future<File> _resizeImage(File imageFile,
      {required int maxWidth, required int maxHeight}) async {
    final compressedImageBytes = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minHeight: 600,
      minWidth: 600,
      quality: 1,
    );

    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final tempFile = File('$tempPath/${imageFile.path.split('/').last}');
    await tempFile.writeAsBytes(compressedImageBytes!);
    return tempFile;
  }

  Future<void> _getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.gray,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingPage(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: _getImage,
                child: CircleAvatar(
                  radius: 10,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Nome',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              CustomTextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              Text(
                'E-mail',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              CustomTextFormField(
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
              ),
              Text(
                'RA',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              CustomTextFormField(
                controller: _studentRecordController,
                keyboardType: TextInputType.name,
              ),
              Text(
                'Nickname',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              CustomTextFormField(
                controller: _nicknameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              Text(
                'Senha',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              CustomTextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.name,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Cadastrar',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
