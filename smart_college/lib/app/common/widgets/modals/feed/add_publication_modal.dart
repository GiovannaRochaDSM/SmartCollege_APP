import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class AddPublicationModal extends StatefulWidget {
  final Future<void> Function(String title, String? publication, String? base64Image) onAddPublication;

  const AddPublicationModal({super.key, required this.onAddPublication});

  @override
  _AddPublicationModalState createState() => _AddPublicationModalState();
}

class _AddPublicationModalState extends State<AddPublicationModal> {
  final ImagePicker _imagePicker = ImagePicker();
  File? selectedImage;
  String? title;
  String? publication;
  bool isLoading = false;

  Future<void> compressAndEncodeImage(File imageFile) async {
    final compressedImageBytes = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minHeight: 200,
      minWidth: 200,
      quality: 90,
    );

    if (compressedImageBytes != null) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final tempFile = File('$tempPath/${imageFile.path.split('/').last}');
      
      await tempFile.writeAsBytes(compressedImageBytes);

      final base64Image = base64Encode(await tempFile.readAsBytes());
      widget.onAddPublication(title!, publication, base64Image);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showMandatoryFields() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          backgroundColor: Colors.white,
          title: Text(
            'Campos obrigatórios',
            style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.darkBlue),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Por favor, preencha os campos obrigatórios.',
            style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                side: const BorderSide(
                  color: AppNewColors.darkBlue,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('OK', style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.darkBlue)),
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
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..scale(1.05),
        child: Container(
          width: 370,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 0,
            color: AppNewColors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Adicionar Publicação',
                      textAlign: TextAlign.center,
                      style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.darkBlue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onChanged: (value) {
                        title = value;
                      },
                      style: AppNewTextStyles.smallerPoppinsRegular.copyWith(color: AppNewColors.textGray),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Conteúdo',
                        labelStyle: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onChanged: (value) {
                        publication = value;
                      },
                      style: AppNewTextStyles.smallerPoppinsRegular.copyWith(color: AppNewColors.textGray),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedImage != null)
                    Image.file(
                      selectedImage!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  else
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: GestureDetector(
                        onTap: () async {
                          await pickImage(ImageSource.gallery);
                        },
                        child: const Icon(
                          Icons.image_search_rounded,
                          size: 80,
                          color: AppNewColors.darkGray,
                        ),
                      ),
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
                        onPressed: () async {
                          if (title != null && title!.isNotEmpty) {
                            if (selectedImage != null) {
                              await compressAndEncodeImage(selectedImage!);
                            } else {
                              widget.onAddPublication(title!, publication, null);
                            }
                            Navigator.of(context).pop();
                          } else {
                            _showMandatoryFields();
                          }
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(color: AppNewColors.darkBlue, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Adicionar',
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
