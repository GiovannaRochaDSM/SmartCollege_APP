import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/pages/detail_page.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/feed_model.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/feed_repository.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  File? _imageFile;
  bool isNull = true;
  String? token;
  late Image imagemReal;
  UserModel? currentUser;
  bool isLoading = false;
  Map<String, bool> likedStatus = {};
  late Future<UserModel?> futureUser;
  final ImagePicker _imagePicker = ImagePicker();
  late Future<List<FeedModel>> futurePublications;
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

    futurePublications = fetchPublications().then((publications) {
      for (var pub in publications) {
        likedStatus[pub.id] = pub.likedBy.contains(currentUser?.nickname);
      }
      setState(() {});
      return publications;
    }).catchError((error) {
      throw Exception('Erro ao buscar publicações: $error');
    });
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
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.selectedImageError);
    }
  }

  Future<File> compressImage(File imageFile) async {
    try {
      final compressedImageBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minHeight: 100,
        minWidth: 100,
        quality: 100,
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

  Widget buildUserAvatar(String? userPhoto) {
    if (userPhoto != null && userPhoto.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 20,
          backgroundImage: MemoryImage(base64Decode(userPhoto)),
        );
      } catch (e) {
        throw Exception('Erro ao decodificar imagem do usuário: $e');
      }
    }
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey,
    );
  }

  Future<List<FeedModel>> fetchPublications() async {
    String? token = await AuthService.getToken();

    try {
      List<FeedModel> publications =
          await feedRepository.getPublications(null, token);

      return publications;
    } on Exception catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Acesso negado. Você não possui vínculo.');
      } else {
        return [];
      }
    }
  }

  Future<void> addPublication(
      String title, String? publication, String? base64Image) async {
    String? token = await AuthService.getToken();

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(AppRoutes.feed),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'publication': publication,
          'image': base64Image,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao adicionar publicação: ${response.body}');
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.addPublicationSuccess);

      setState(() {
        futurePublications = fetchPublications();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.addPublicationError);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showAddPublicationModal() async {
    File? selectedImage;
    String? title;
    String? publication;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.identity()..scale(1.05),
                child: Container(
                  width: 370,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 10,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Adicionar Publicação',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.normalTextBold
                                    .copyWith(color: AppColors.titlePurple)),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              decoration:
                                  const InputDecoration(labelText: 'Título'),
                              onChanged: (value) {
                                title = value;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextField(
                              decoration:
                                  const InputDecoration(labelText: 'Conteúdo'),
                              onChanged: (value) {
                                publication = value;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (selectedImage != null)
                            Image.file(
                              selectedImage!,
                              width: 150,
                              height: 150,
                            )
                          else
                            const SizedBox(
                              height: 200,
                              child: Icon(Icons.image_search_rounded,
                                  size: 70, color: AppColors.gray),
                            ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () async {
                              final pickedFile = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.titlePurple),
                            label: Text('Selecionar nova imagem',
                                style: AppTextStyles.smallText
                                    .copyWith(color: AppColors.titlePurple)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancelar',
                                    style: AppTextStyles.smallText
                                        .copyWith(color: AppColors.gray)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  String? base64Image;
                                  if (selectedImage != null) {
                                    final compressedImage =
                                        await compressImage(selectedImage!);
                                    final bytes =
                                        await compressedImage.readAsBytes();
                                    base64Image = base64Encode(bytes);
                                  }
                                  if (title != null && title!.isNotEmpty) {
                                    await addPublication(
                                        title!, publication, base64Image);
                                    Navigator.of(context).pop();
                                  } else {
                                    _showMandatoryFields();
                                  }
                                },
                                child: Text('Adicionar',
                                    style: AppTextStyles.smallText.copyWith(
                                        color: AppColors.titlePurple)),
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
          },
        );
      },
    );
  }

  void _showMandatoryFields() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Campos obrigatórios',
              style: AppTextStyles.normalTextBold
                  .copyWith(color: AppColors.titlePurple),
              textAlign: TextAlign.center),
          content: const Text('Por favor, preencha os campos obrigatórios.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK',
                  style: AppTextStyles.smallerTextBold
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Text(
          'FEED',
          style: AppTextStyles.normalText.copyWith(color: AppColors.white),
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
        actions: currentUser?.isCoord == true
            ? [
                IconButton(
                  icon: const Icon(Icons.add, size: 25),
                  onPressed: _showAddPublicationModal,
                ),
              ]
            : null,
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
      ),
      drawer: const CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<FeedModel>>(
              future: futurePublications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final publications = snapshot.data;

                return ListView.builder(
                  itemCount: publications?.length ?? 0,
                  itemBuilder: (context, index) {
                    final publication = publications![index];
                    var isLiked = likedStatus[publication.id] ??
                        publication.likedBy.contains(currentUser?.nickname);

                    return GestureDetector(
                      onTap: () {
                        if (currentUser?.isCoord == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(
                                publicationId: publication.id,
                                universityId: publication.universityId,
                                userPhoto: publication.userPhoto ??
                                    'assets/images/logo.png',
                                likes: publication.likes,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(AppSnackBar.restrictedAccess);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.all(2.0),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: (publication.userPhoto !=
                                                        null &&
                                                    publication
                                                        .userPhoto!.isNotEmpty)
                                                ? MemoryImage(base64Decode(
                                                        publication.userPhoto!))
                                                    as ImageProvider<Object>
                                                : const AssetImage(
                                                    'assets/images/logo.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        publication.userName ??
                                            'Usuário desconhecido',
                                        style: AppTextStyles.smallText.copyWith(
                                            color: AppColors.lightBlack),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(publication.dateTime),
                                    style: AppTextStyles.smallerText
                                        .copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          publication.title!,
                                          style: AppTextStyles.normalText,
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          publication.publication ?? '',
                                          style: AppTextStyles.smallText
                                              .copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  if (publication.image != null &&
                                      publication.image!.isNotEmpty)
                                    GestureDetector(
                                      onDoubleTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: Image.memory(
                                              base64Decode(publication.image!),
                                              fit: BoxFit.fitWidth,
                                              height: 400,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          image: DecorationImage(
                                            image: MemoryImage(base64Decode(
                                                publication.image!)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: isLiked
                                        ? (Matrix4.identity()..scale(1.1))
                                        : Matrix4.identity(),
                                    child: IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            isLiked ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        try {
                                          final likeUrl = Uri.parse(
                                              '${AppRoutes.feed}${publication.id}/like');
                                          final token =
                                              await AuthService.getToken();
                                          final response = await http.post(
                                            likeUrl,
                                            headers: {
                                              'Authorization': 'Bearer $token',
                                            },
                                          );

                                          if (response.statusCode == 200) {
                                            setState(() {
                                              likedStatus[publication.id] =
                                                  !isLiked;
                                              publication.likes +=
                                                  isLiked ? -1 : 1;
                                              if (isLiked) {
                                                publication.likedBy.remove(
                                                    currentUser!.nickname);
                                              } else {
                                                publication.likedBy
                                                    .add(currentUser!.nickname);
                                              }
                                              isLiked = !isLiked;
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              isLiked
                                                  ? AppSnackBar.dislikeError
                                                  : AppSnackBar.likeError,
                                            );
                                          }
                                        } catch (e) {
                                          throw Exception(
                                              'Erro ao conectar com o servidor: $e');
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
