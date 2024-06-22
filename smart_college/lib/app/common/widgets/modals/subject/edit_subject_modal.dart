import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';

class EditSubjectModal extends StatefulWidget {
  final SubjectModel subject;

  const EditSubjectModal({super.key, required this.subject});

  @override
  _EditSubjectModalState createState() => _EditSubjectModalState();
}

class _EditSubjectModalState extends State<EditSubjectModal> {
  late TextEditingController _nameController;
  late TextEditingController _acronymController;
  late TextEditingController _gradesController;
  late TextEditingController _absenceController;

  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject.name);
    _acronymController = TextEditingController(text: widget.subject.acronym);
    _gradesController =
        TextEditingController(text: widget.subject.grades?.join(",") ?? '');
    _absenceController =
        TextEditingController(text: widget.subject.abscence?.toString() ?? '');

    _httpClient = HttpClient();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _acronymController.dispose();
    _gradesController.dispose();
    _absenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Text(
          'EDITAR MATÉRIA',
          style: AppTextStyles.normalText.copyWith(color: AppColors.white),
          textAlign: TextAlign.center,
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
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 70, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle:
                    AppTextStyles.normalText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),
              ),
            ),
            const SizedBox(height: 45),
            TextField(
              controller: _acronymController,
              decoration: InputDecoration(
                labelText: 'Sigla',
                labelStyle:
                    AppTextStyles.normalText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),
              ),
            ),
            const SizedBox(height: 45),
            TextField(
              controller: _gradesController,
              decoration: InputDecoration(
                labelText: 'Notas',
                labelStyle:
                    AppTextStyles.normalText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 45),
            TextField(
              controller: _absenceController,
              decoration: InputDecoration(
                labelText: 'Faltas',
                labelStyle:
                    AppTextStyles.normalText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 80),
            PrimaryButton(
              text: 'Salvar',
              onPressed: () {
                _updateSubject(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateSubject(BuildContext context) async {
    try {
      String newName = _nameController.text;
      String newAcronym = _acronymController.text;
      List<int>? newGrades;
      int? newAbsence;

      if (_gradesController.text.isNotEmpty) {
        newGrades = _gradesController.text
            .split(',')
            .map((grade) => int.parse(grade.trim()))
            .toList();
      }

      if (_absenceController.text.isNotEmpty) {
        newAbsence = int.parse(_absenceController.text);
      }

      SubjectModel updatedSubject = SubjectModel(
        id: widget.subject.id,
        name: newName,
        acronym: newAcronym,
        grades: newGrades,
        abscence: newAbsence,
      );

      await _performUpdate(updatedSubject);

      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.subjectUpdatedSuccess);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.subjectUpdatedError);
    }
  }

  Future<void> _performUpdate(SubjectModel updatedSubject) async {
    final SubjectRepository subjectRepository =
        SubjectRepository(client: _httpClient);
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    await subjectRepository.updateSubject(updatedSubject, token);
    setState(() {});
  }

  void showEditSubjectModal(BuildContext context, SubjectModel subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditSubjectModal(subject: subject),
        );
      },
    );
  }
}
