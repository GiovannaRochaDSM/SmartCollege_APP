import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_field.dart';
import 'package:smart_college/app/services/auth_service.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/data/repositories/user_repository.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

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

  final ImagePicker _imagePicker = ImagePicker();
  final _bondController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureUser = UserHelper.fetchUser();
    futureUser.then((value) => {lerImagem(value.photo)});
    userRepository = UserRepository(client: HttpClient());
  }

  Future<void> lerImagem(String? photo) async {
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
        bond: _bondController.text == '' ? false : true,
        studentRecord: '',
        isCoord: false,
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

  Future<File> _compressImage(File imageFile) async {
    final compressedImageBytes = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minHeight: 600,
      minWidth: 600,
      quality: 80,
    );

    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final tempFile = File('$tempPath/${imageFile.path.split('/').last}');
    await tempFile.writeAsBytes(compressedImageBytes!);

    return tempFile;
  }

  Future<void> deleteAccount() async {
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');

      await userRepository.deleteUser(user.id, token);
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.userDeletedSuccess);

      AuthService.logout(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.userDeletedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meu perfil',
          style:
              AppTextStyles.smallTextBold.copyWith(color: AppColors.lightBlack),
          textAlign: TextAlign.right,
        ),
        backgroundColor: AppColors.purple,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<UserModel>(
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
                  _bondController.text = user.bond.toString();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                              radius: 80,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (isNull ? null : imagemReal.image),
                              child: _imageFile == null && isNull
                                  ? const Icon(
                                      Icons.camera_alt,
                                      size: 50,
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
                                backgroundColor: AppColors.purple,
                                radius: 20,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Nome',
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'E-mail',
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _nicknameController,
                            labelText: 'Apelido',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  updateUser();
                                },
                                child: Text('Salvar alterações',
                                    style: AppTextStyles.smallerText.copyWith(
                                        color: AppColors.titlePurple)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  deleteAccount();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(
                                  'Excluir conta',
                                  style: AppTextStyles.smallerText
                                      .copyWith(color: AppColors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() async {
    try {
      Navigator.of(context).pop();
      String? token = await AppStrings.secureStorage.read(key: 'token');

      setState(() {
        _imageFile = null;
      });

      final ByteData assetByteData =
          await rootBundle.load('assets/images/user.png');
      final Uint8List assetBytes = assetByteData.buffer.asUint8List();
      final String base64Image = base64Encode(assetBytes);

      final updatedUser = user.updatePhoto(base64Image);
      await userRepository.updateUser(updatedUser, token);

      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.removePhotoSuccess);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.removePhotoError);
    }
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
                title: Text(
                  'Escolher da galeria',
                  style: AppTextStyles.smallTextBold.copyWith(color: AppColors.gray)
                ),
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
                title: Text(
                  'Tirar foto',
                  style: AppTextStyles.smallTextBold.copyWith(color: AppColors.gray)
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.purple,
                  child: Icon(
                    Icons.delete,
                    color: AppColors.white,
                  ),
                ),
                title: Text(
                  'Remover foto',
                  style: AppTextStyles.smallTextBold.copyWith(color: AppColors.gray)
                ),
                onTap: _removeImage,
              ),
            ],
          ),
        );
      },
    );
  }
}