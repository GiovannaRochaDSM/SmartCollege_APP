import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/pages/login_page.dart';
import 'package:smart_college/app/pages/onboarding_page.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String nickname = _nicknameController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
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
      'nickname': nickname,
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
          builder: (context) => const LoginPage(),
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
      quality: 90,
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

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
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
        title: Text('Cadastro',
            style: AppTextStyles.normalText.copyWith(color: AppColors.white)),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.help_outline_rounded, color: AppColors.white),
            onPressed: _showPasswordPolicyAlert,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.purple,
                        width: 5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 60,
                              color: AppColors.purple,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _showOptionsBottomSheet();
                      },
                      child: const CircleAvatar(
                        backgroundColor: AppColors.purple,
                        radius: 30,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _nicknameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Apelido',
                    labelStyle: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray),
                    prefixIcon: const Icon(Icons.alternate_email_rounded,
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
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray),
                    prefixIcon:
                        const Icon(Icons.person, color: AppColors.purple),
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
              const SizedBox(height: 30),
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
                    labelText: 'E-mail',
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
              const SizedBox(height: 30),
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
                    labelText: 'Senha',
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
              const SizedBox(height: 40),
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

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                leading: const Icon(
                  Icons.photo_camera,
                  color: AppColors.gray,
                  size: 24,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    'Tirar uma foto',
                    style:
                        AppTextStyles.smallText.copyWith(color: AppColors.gray),
                  ),
                ),
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.gray,
                  size: 24,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    'Escolher da galeria',
                    style:
                        AppTextStyles.smallText.copyWith(color: AppColors.gray),
                  ),
                ),
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
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
}
