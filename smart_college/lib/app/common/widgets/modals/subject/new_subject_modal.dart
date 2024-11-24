import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/pages/subject/subject_page.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_elevated_button.dart';

class NewSubjectModal extends StatefulWidget {
  const NewSubjectModal({super.key});

  @override
  _NewSubjectModalState createState() => _NewSubjectModalState();
}

class _NewSubjectModalState extends State<NewSubjectModal> {
  late TextEditingController _nameController;
  late TextEditingController _acronymController;
  late TextEditingController _notesController;

  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _acronymController = TextEditingController();
    _notesController = TextEditingController();

    _httpClient = HttpClient();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _acronymController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nova matéria',
              style: AppNewTextStyles.mediumBalooTitle.copyWith(color: AppNewColors.lightBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: AppNewTextStyles.mediumExtraLight.copyWith(color: AppNewColors.textGray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppNewColors.textGray, width: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 45),
            TextField(
              controller: _acronymController,
              decoration: InputDecoration(
                labelText: 'Sigla',
                labelStyle: AppNewTextStyles.mediumExtraLight.copyWith(color: AppNewColors.textGray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppNewColors.textGray, width: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Anotações',
                labelStyle: AppNewTextStyles.mediumExtraLight.copyWith(color: AppNewColors.textGray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppNewColors.textGray, width: 1.0),
                ),
              ),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 30),
            CustomElevatedButton(
              text: 'Adicionar',
              onPressed: () {
                _addSubject(context);
              },
              buttonColor: AppNewColors.lightBlue,
              borderColor: AppNewColors.lightBlue,
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
      String newNotes = _notesController.text;

      SubjectModel newSubject = SubjectModel(
        id: '',
        name: newName,
        acronym: newAcronym,
        notes: newNotes,
      );

      await _performAdd(newSubject);

      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectAddSuccess);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectAddError);
    }
  }

  Future<void> _performAdd(SubjectModel newSubject) async {
    final SubjectRepository subjectRepository = SubjectRepository(client: _httpClient);
    String? token = await AppStrings.secureStorage.read(key: 'token');

    try {
      bool success = await subjectRepository.addSubject(newSubject, token);

      if (success) {
        print(success);
        _updateAndReloadPage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectAddError);
    }
  }

  Future<void> _updateAndReloadPage() async {
    Navigator.pop(context, true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SubjectPage(),
      ),
    );
  }
}
