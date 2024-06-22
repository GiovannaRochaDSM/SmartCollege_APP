import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';

class NewSubjectModal extends StatefulWidget {
  const NewSubjectModal({super.key});

  @override
  _NewSubjectModalState createState() => _NewSubjectModalState();
}

class _NewSubjectModalState extends State<NewSubjectModal> {
  late TextEditingController _nameController;
  late TextEditingController _acronymController;
  late TextEditingController _gradesController;
  late TextEditingController _absenceController;

  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _acronymController = TextEditingController();
    _gradesController = TextEditingController();
    _absenceController = TextEditingController();

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
          'NOVA MATÉRIA',
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
              text: 'Adicionar',
              onPressed: () {
                _addSubject(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addSubject(BuildContext context) async {
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

      SubjectModel newSubject = SubjectModel(
        id: '',
        name: newName,
        acronym: newAcronym,
        grades: newGrades,
        abscence: newAbsence,
      );

      await _performAdd(newSubject);

      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectAddSuccess);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectAddError);
    }
  }

  Future<void> _performAdd(SubjectModel newSubject) async {
    final SubjectRepository subjectRepository =
        SubjectRepository(client: _httpClient);
    String? token = await AppStrings.secureStorage.read(key: 'token');
    await subjectRepository.addSubject(newSubject, token);
  }
}

void showNewSubjectModal(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const NewSubjectModal(),
    ),
  );
}
