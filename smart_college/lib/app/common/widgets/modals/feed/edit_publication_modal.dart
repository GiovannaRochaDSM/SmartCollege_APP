import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/pages/feed/feed_page.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/models/feed_model.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/feed_repository.dart';

class EditPublicationModal extends StatefulWidget {
  final FeedModel publication;

  const EditPublicationModal({super.key, required this.publication});

  @override
  _EditPublicationModalState createState() => _EditPublicationModalState();
}

class _EditPublicationModalState extends State<EditPublicationModal> {
  bool isNull = true;
  File? _selectedImage;
  late Image imagemReal;
  UserModel? currentUser;
  String? _existingImageUrl;
  late Future<UserModel?> futureUser;
  late TextEditingController _titleController;
  late Future<List<FeedModel>> futurePublications;
  late TextEditingController _publicationController;
  final FeedRepository feedRepository = FeedRepository(client: HttpClient());

  @override
  void initState() {
    super.initState();
    _existingImageUrl = widget.publication.image;
    _titleController = TextEditingController(text: widget.publication.title);
    _publicationController = TextEditingController(text: widget.publication.publication);
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _publicationController.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? compressedImage = (await compressImage(File(pickedFile.path))) as File?;

      setState(() {
        _selectedImage = compressedImage;
      });
    }
  }

  Future<File> compressImage(File imageFile) async {
    try {
      final compressedImageBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minHeight: 200,
        minWidth: 200,
        quality: 90,
      );

      if (compressedImageBytes == null) {
        throw Exception('Falha ao comprimir a imagem.');
      }

      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final tempFile = File('$tempPath/${imageFile.path.split('/').last}');
      await tempFile.writeAsBytes(compressedImageBytes);

      return tempFile;
    } catch (e) {
      throw Exception('Erro ao comprimir a imagem: $e');
    }
  }

  Future<void> _updateAndReloadPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const FeedPage(),
      ),
    );
  }

  Future<void> _updatePublication(FeedModel feed) async {
    try {
      String? token = await AuthService.getToken();

      FeedModel updatedFeed = FeedModel(
        id: feed.id,
        title: _titleController.text,
        publication: _publicationController.text,
        image: feed.image,
        userId: feed.userId,
        userName: feed.userName,
        userEmail: feed.userEmail,
        universityId: feed.universityId,
        universityName: feed.universityName,
      );

      if (_selectedImage != null) {
        final compressedImage = await compressImage(_selectedImage!);
        List<int> imageBytes = compressedImage.readAsBytesSync();
        String base64Image = base64Encode(imageBytes);

        updatedFeed = updatedFeed.updateImage(base64Image);
      }

      bool success = await feedRepository.updatePublication(updatedFeed, token);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.feedUpdatedSuccess);
        _updateAndReloadPage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.feedUpdatedError);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.feedUpdatedError);
    }
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: pickImage,
      child: _selectedImage != null
          ? Image.file(
              _selectedImage!,
              height: 250,
              width: 250,
              fit: BoxFit.cover,
            )
          : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
              ? Image.memory(
                  const Base64Decoder().convert(_existingImageUrl!),
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                )
              : const SizedBox(
                  height: 250,
                  width: 250, 
                  child: Icon(Icons.image, size: 80),
                )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..scale(1.05),
        child: Container(
          width: 370,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 0,
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Editar Publicação',
                      textAlign: TextAlign.center,
                      style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.darkBlue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      style: AppNewTextStyles.smallerPoppinsRegular
                          .copyWith(color: AppNewColors.textGray),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _publicationController,
                      decoration: InputDecoration(
                        labelText: 'Conteúdo',
                        labelStyle: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      style: AppNewTextStyles.smallerPoppinsRegular.copyWith(color: AppNewColors.textGray),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildImage(),
                  TextButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                      color: AppNewColors.darkBlue),
                    label: Text('Selecionar nova imagem',
                      style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.darkBlue)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _updatePublication(widget.publication);
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(
                            color: AppNewColors.darkBlue,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Salvar',
                          style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.darkBlue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
