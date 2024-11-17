import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_elevated_button.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/user_repository.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_field.dart';
import 'package:smart_college/app/common/widgets/dialogs/request_bond_dialog.dart';
import 'package:smart_college/app/common/widgets/modals/user/reset_password_modal.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  File? _imageFile;
  bool isNull = true;
  late UserModel user;
  late Image imagemReal;
  late Future<UserModel> futureUser;
  late UserRepository userRepository;
  bool isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _universityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureUser = UserHelper.fetchUser();
    futureUser.then((value) => {readImage(value.photo)});
    userRepository = UserRepository(client: HttpClient());
  }

  Future<void> readImage(String? photo) async {
    if (photo != null) {
      imagemReal = Image.memory(const Base64Decoder().convert(photo));
      setState(() {
        isNull = false;
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

  Future<File> _compressImage(File imageFile) async {
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

  void _removeImage() async {
    try {
      Navigator.of(context).pop();
      String? token = await AppStrings.secureStorage.read(key: 'token');

      setState(() {
        _imageFile = null;
      });

      final ByteData assetByteData =
          await rootBundle.load('assets/images/couple.png');
      final Uint8List assetBytes = assetByteData.buffer.asUint8List();
      final String base64Image = base64Encode(assetBytes);

      final updatedUser = user.updatePhoto(base64Image);
      await userRepository.updateUser(updatedUser, token);

      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.removePhotoSuccess);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const UserPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.removePhotoError);
    }
  }

  Future<void> updateUser() async {
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');

      UserModel updatedUser = UserModel(
        id: user.id,
        name: _nameController.text,
        nickname: _nicknameController.text,
        email: _emailController.text,
        photo: user.photo,
        password: _passwordController.text,
        bond: user.bond,
        studentRecord: '',
        universityId: user.universityId,
        isCoord: user.isCoord,
      );

      if (_imageFile != null) {
        final compressedImage = await _compressImage(_imageFile!);
        List<int> imageBytes = compressedImage.readAsBytesSync();
        String base64Image = base64Encode(imageBytes);
        updatedUser = updatedUser.updatePhoto(base64Image);
      }

      bool success = await userRepository.updateUser(updatedUser, token);

      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(AppSnackBar.userUpdatedSuccess);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(AppSnackBar.userUpdatedError);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.userUpdatedError);
    }
  }

  Future<void> deleteAccount() async {
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');

      bool confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirmar exclusão',
              textAlign: TextAlign.center,
              style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.lightBlue),
            ),
            content: Text(
                'Tem certeza que deseja excluir sua conta? Esta ação é irreversível.', style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),),
                
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar', style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  side: const BorderSide(
                    color: AppNewColors.red,
                    width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Excluir',
                  style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.red),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        await userRepository.deleteUser(user.id, token);
        ScaffoldMessenger.of(context)
            .showSnackBar(AppSnackBar.userDeletedSuccess);
        AuthService.logout(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.userDeletedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppNewColors.lightBlue,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: AppNewColors.lightBlue,
        toolbarHeight: 78,
        title: Text(
          'Meu perfil',
          style: AppNewTextStyles.balooTitle.copyWith(color: AppColors.white),
          textAlign: TextAlign.right,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_rounded, size: 25),
            onPressed: () {
              (
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                backgroundColor: Colors.white,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const ResetPasswordModal(),
                  );
                },
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: AppColors.white, size: 30),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FutureBuilder<UserModel>(
                  future: futureUser,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar usuário: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (snapshot.hasData) {
                      user = snapshot.data!;
                      _nameController.text = user.name;
                      _emailController.text = user.email;
                      _nicknameController.text = user.nickname;
                      _passwordController.text = user.password;
                      _universityController.text = user.universityName!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppNewColors.darkGray,
                                    width: 5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 95,
                                  backgroundColor: AppNewColors.darkGray,
                                  backgroundImage: _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (isNull ? null : imagemReal.image),
                                  child: _imageFile == null && isNull
                                      ? const Icon(
                                          Icons.camera_alt,
                                          size: 60,
                                          color: Colors.white,
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
                                    backgroundColor: AppNewColors.darkGray,
                                    radius: 30,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Apelido',
                                  style: AppNewTextStyles.mediumPoppinsMedium.copyWith(
                                      color: AppNewColors.textGray),
                                ),
                                CustomTextField(
                                  controller: _nicknameController,
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Nome',
                                  style: AppNewTextStyles.mediumPoppinsMedium.copyWith(
                                      color: AppNewColors.textGray),
                                  textAlign: TextAlign.left,
                                ),
                                CustomTextField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'E-mail',
                                  style: AppNewTextStyles.mediumPoppinsMedium.copyWith(
                                      color: AppNewColors.textGray),
                                  textAlign: TextAlign.left,
                                ),
                                CustomTextField(
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
                                const SizedBox(height: 10),
                                Text(
                                  'Instituição',
                                  style: AppNewTextStyles.mediumPoppinsMedium.copyWith(
                                      color: AppNewColors.textGray),
                                  textAlign: TextAlign.left,
                                ),
                                CustomTextField(
                                  controller: _universityController,
                                  keyboardType: TextInputType.text,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Ainda não possui vínculo com a sua instituição?',
                                  style: AppTextStyles.smallerText.copyWith(
                                      color: AppColors.lightBlack),
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return RequestBondDialog(userId: user.id);
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Solicite aqui',
                                    style: AppNewTextStyles.smallPoppinsRegular.copyWith(
                                        color: AppNewColors.darkBlue,
                                        decoration: TextDecoration.underline),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomElevatedButton(
                                      onPressed: () {
                                        updateUser();
                                      },
                                      width: 124,
                                      text: 'Salvar alterações',
                                      borderColor: AppNewColors.lightBlue,
                                      buttonColor: AppNewColors.white,
                                      textColor: AppNewColors.lightBlue,
                                    ),
                                    CustomElevatedButton(
                                      onPressed: () {
                                        deleteAccount();
                                      },
                                      width: 124,
                                      text: 'Excluir',
                                      borderColor: AppNewColors.red,
                                      buttonColor: AppNewColors.red,
                                      textColor: AppNewColors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.purple,
                  child: Icon(
                    Icons.photo_library,
                    color: AppColors.white,
                  ),
                ),
                title: Text('Escolher da galeria',
                    style: AppTextStyles.smallTextBold
                        .copyWith(color: AppColors.gray)),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.purple,
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                  ),
                ),
                title: Text('Tirar foto',
                    style: AppTextStyles.smallTextBold
                        .copyWith(color: AppColors.gray)),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.purple,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.white,
                  ),
                ),
                title: Text('Remover foto',
                    style: AppTextStyles.smallTextBold
                        .copyWith(color: AppColors.gray)),
                onTap: _removeImage,
              ),
            ],
          ),
        );
      },
    );
  }

  void showResetPasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
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
}
