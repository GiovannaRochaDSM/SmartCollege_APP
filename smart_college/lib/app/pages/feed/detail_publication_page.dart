import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/pages/feed/feed_page.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/feed_model.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/feed_repository.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/common/widgets/modals/feed/edit_publication_modal.dart';

class DetailPublicationPage extends StatefulWidget {
  final String publicationId;
  final String universityId;
  final String userPhoto;
  final int likes;

  const DetailPublicationPage(
      {super.key,
      required this.publicationId,
      required this.universityId,
      required this.userPhoto,
      required this.likes});

  @override
  _DetailPublicationPageState createState() => _DetailPublicationPageState();
}

class _DetailPublicationPageState extends State<DetailPublicationPage> {
  File? _imageFile;
  bool isNull = true;
  late Image imagemReal;
  UserModel? currentUser;
  bool isLoading = false;
  late Future<UserModel?> futureUser;
  late Future<FeedModel> futurePublication;
  final ImagePicker _imagePicker = ImagePicker();
  final _titleController = TextEditingController();
  final _publicationController = TextEditingController();
  final FeedRepository feedRepository = FeedRepository(client: HttpClient());

  @override
  void initState() {
    super.initState();
    futureUser = UserHelper.fetchUser().then((user) {
      if (user != null) {
        setState(() {
          currentUser = user;
        });
      }
    });
    futurePublication = fetchSinglePublication(widget.publicationId);
  }

  Future<FeedModel> fetchSinglePublication(String publicationId) async {
    String? token = await AuthService.getToken();

    try {
      final publication = await feedRepository.getPublicationById(publicationId, token);

      return publication;
    } catch (e) {
      throw Exception('Falha ao buscar a publicação.');
    }
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
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.selectedImageError);
    }
  }

  Future<File> compressImage(File imageFile) async {
    try {
      final compressedImageBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minHeight: 100,
        minWidth: 100,
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

  Future<void> deletePublication(String publicationId) async {
    String? token = await AuthService.getToken();

    try {
      bool isDeleted = await feedRepository.deletePublication(publicationId, token);

      if (isDeleted) {
        setState(() {
          futurePublication;
        });
        _updateAndReload();
        
        ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.publicationDeletedSuccess);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.feedUpdatedSuccess);
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Excluir Publicação',
              textAlign: TextAlign.center,
              style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.darkBlue),
            ),
            content: Text(
              'Você tem certeza que deseja excluir esta publicação?',
              style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                ),
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
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          );
        },
    ) ??
    false;
  }

  Future<void> updateFeed(FeedModel feed) async {
    try {
      String? token = await AuthService.getToken();

      FeedModel updatedFeed = FeedModel(
        id: feed.id,
        title: _titleController.text,
        publication: _publicationController.text,
        image: feed.image,
        likes: feed.likes,
        likedBy: feed.likedBy,
        userId: feed.userId,
        userName: feed.userName,
        userEmail: feed.userEmail,
        universityId: feed.universityId,
        universityName: feed.universityName,
      );

      if (_imageFile != null) {
        final compressedImage = await compressImage(_imageFile!);
        List<int> imageBytes = compressedImage.readAsBytesSync();
        String base64Image = base64Encode(imageBytes);

        updatedFeed = updatedFeed.updateImage(base64Image);
      }

      bool success = await feedRepository.updatePublication(updatedFeed, token);

      if (success) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.feedUpdatedError);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.feedUpdatedError);
    }
  }

  void _showEditModal(FeedModel subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPublicationModal(
          publication: subject,
        );
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage(subject.id, subject.universityId, subject.userPhoto!, subject.likes);
      }
    });
  }

  Future<void> _updateAndReloadPage(String publicationId, String universityId,String userPhoto, int likes) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPublicationPage(
          publicationId: publicationId,
          universityId: universityId,
          userPhoto: userPhoto,
          likes: likes,
        ),
      ),
    );
  }

  Future<void> _updateAndReload() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const FeedPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppNewColors.darkBlue,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: AppNewColors.darkBlue,
        actions: [
          FutureBuilder<FeedModel>(
            future: futurePublication,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError) {
                return Container();
              }

              final publication = snapshot.data;

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mode_edit_outlined,
                      color: Colors.white, size: 30.0),
                    onPressed: () {
                      if (publication != null) {
                        _showEditModal(publication);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 30.0),
                    onPressed: () {
                      if (publication != null) {
                        _confirmDelete(context).then((shouldDelete) {
                          if (shouldDelete) {
                            deletePublication(publication.id);
                          }
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<FeedModel>(
                      future: futurePublication,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erro: ${snapshot.error}'));
                        }

                        final publication = snapshot.data;

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(vertical: 1.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: (publication?.userPhoto != null && publication!.userPhoto!.isNotEmpty)
                                              ? MemoryImage(base64Decode(publication.userPhoto!)) as ImageProvider<Object>
                                              : const AssetImage('assets/images/logo.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8.0),
                                          Text(
                                            publication?.userName ?? 'Usuário desconhecido',
                                            style: AppNewTextStyles.poppinsMedium.copyWith(color:AppNewColors.textGray),
                                          ),
                                          Text(
                                            publication?.userEmail ?? 'Email desconhecido',
                                            style: AppNewTextStyles.smallExtraLight.copyWith(color:AppNewColors.textGray),
                                          ),
                                          Text(
                                            publication?.universityName ?? 'Universidade desconhecida',
                                            style: AppNewTextStyles.smallExtraLight.copyWith(color:AppNewColors.textGray),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 1.0, top: 4.0),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(publication?.dateTime ?? DateTime.now()),
                                      style: AppNewTextStyles.smallExtraLight.copyWith(color: AppNewColors.textGray),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ListTile(
                                  title: Center(
                                    child: Text(publication?.title ?? 'Título não disponível',
                                      style: AppNewTextStyles.bigPoppinsMedium.copyWith(color: AppNewColors.textGray),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (publication?.publication != null && publication!.publication!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(publication.publication!,
                                            style: AppNewTextStyles.smallExtraLight.copyWith(color:AppNewColors.textGray),
                                          ),
                                        ),
                                      if (publication?.image != null && publication!.image!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 60.0),
                                          child: Center(
                                            child: Image.memory(
                                              base64Decode(publication.image!),
                                              fit: BoxFit.cover,
                                              height: 330,
                                              width: 330,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.favorite,
                                            color: AppNewColors.red, 
                                            size: 25,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${publication?.likes ?? 0}',
                                            style: AppTextStyles.smallerText.copyWith(color: AppColors.gray),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
